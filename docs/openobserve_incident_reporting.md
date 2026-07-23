# OpenObserve 全量 Logger 事件直传

本地 Docker Compose、Nginx 和初始化脚本位于 [`deploy/openobserve`](../deploy/openobserve/README.md)。

## 数据链路

App 不依赖业务后台：

```text
Flutter App -> HTTPS Nginx 摄取入口 -> 本机 OpenObserve
```

Nginx 只暴露一个固定写入路径，校验可轮换的 `X-Ingest-Key`，并在服务器内部添加 OpenObserve Basic Authorization。OpenObserve 管理员密码绝不能写入 App。

## App 构建参数

```bash
fvm flutter run \
  --dart-define=OPENOBSERVE_INGEST_URL=https://observe.example.jp/app-events \
  --dart-define=OPENOBSERVE_INGEST_KEY=REPLACE_WITH_RANDOM_UPLOAD_KEY \
  --dart-define=APP_ENVIRONMENT=production
```

未同时提供 `OPENOBSERVE_INGEST_URL` 和 `OPENOBSERVE_INGEST_KEY` 时，远程上报关闭，本地文件日志、全量事件 Outbox 和错误 Incident Outbox 仍正常工作。

## 采集范围

- `logI`、`logW`、`logE` 以及直接通过 `package:logging` 产生的所有级别记录都会上报。
- `print`、`debugPrint` 按当前要求不采集。
- 普通 Logger 记录使用 `record_type: log`。
- 需要错误堆栈和前置操作轨迹的错误事件，会额外产生 `record_type: incident` 记录；可用同一个 `incident_id` 关联错误日志和详细事件。
- 每条记录包含当前可用的 `merchant_id`、`machine_id`、App 版本、平台、会话 ID 和环境字段。

上传 Key 不是商户或点餐机登录账号，但仍应视为可轮换凭据。APK/EXE 中的构建参数无法被视为真正的秘密，因此服务端必须同时配置限流、请求体大小限制和路径隔离。

## Nginx 摄取入口

先生成两个值：

```bash
openssl rand -hex 32
printf '%s' 'OPENOBSERVE_EMAIL:OPENOBSERVE_PASSWORD' | base64
```

不要把生成结果提交到 Git。下面配置中的值只保存在服务器：

```nginx
limit_req_zone $binary_remote_addr zone=incident_ingest:10m rate=5r/s;

server {
    listen 443 ssl http2;
    server_name observe.example.jp;

    ssl_certificate /etc/letsencrypt/live/observe.example.jp/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/observe.example.jp/privkey.pem;

    location ~ ^/app-(events|incidents)$ {
        if ($http_x_ingest_key != "REPLACE_WITH_RANDOM_UPLOAD_KEY") {
            return 401;
        }

        limit_req zone=incident_ingest burst=20 nodelay;
        limit_except POST { deny all; }
        client_max_body_size 2m;

        proxy_set_header Authorization "Basic REPLACE_WITH_BASE64_CREDENTIALS";
        proxy_set_header Content-Type "application/json";
        rewrite ^/app-(events|incidents)$ /api/default/app_events/_json break;
        proxy_pass http://127.0.0.1:5080;
        proxy_connect_timeout 10s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }

    location / {
        # 管理页面只允许公司网络或 VPN；请替换为实际网段。
        allow 192.0.2.0/24;
        deny all;
        proxy_pass http://127.0.0.1:5080;
    }
}
```

如果管理页面使用独立域名，建议把摄取入口和管理页面拆成两个 `server` 块。

## OpenObserve 请求格式

App 每次发送一个 JSON 数组，普通 Logger 事件最多每批 100 条。示例中的详细错误记录为 `record_type: incident`：

```json
[
  {
    "schema_version": 1,
    "record_type": "incident",
    "_timestamp": "2026-07-22T01:30:00.000Z",
    "incident_id": "8d9f4f5e-1ad7-4bc8-990b-533f99ba5b62",
    "event_code": "PAYMENT_FAILED",
    "severity": "error",
    "message": "Payment failed",
    "occurred_at": "2026-07-22T01:30:00.000Z",
    "merchant_id": "shop-1001",
    "machine_id": "machine-2001",
    "session_id": "50dc5ef8-d003-4d1b-a6df-4f9e44073867",
    "app_version": "2.9.5",
    "build_number": "181",
    "platform": "windows",
    "environment": "production",
    "flow_id": "37e3945a-4130-48ef-aadc-8c823498dbb0",
    "data": {
      "phase": "payment_confirm",
      "order_id": "order-3001"
    },
    "breadcrumbs": [],
    "error": "TimeoutException",
    "stack_trace": "#0 PaymentService.confirm ...",
    "retry_count": 0
  }
]
```

`_timestamp` 使用事件实际发生时间。断网恢复后补传不会把补传时间误认为事件发生时间。队列另外保存单调入队序号，即使多条日志时间戳完全相同，也能保持原始先后顺序。

只有 OpenObserve 返回 HTTP 200，并且 `status` 中成功条数等于本批条数、`failed == 0` 时，App 才从本地 Outbox 删除事件。

## 离线与重试

- 所有 Logger 事件先写 Hive，再按批触发上传。
- App 初始化 Hive 之前产生的启动日志先保存在内存缓冲区，初始化完成后按原顺序写入 Hive；缓冲区最多 500 条。
- 上传失败不会删除本地事件。
- 重试间隔依次为 5 秒、30 秒、2 分钟、10 分钟、30 分钟。
- 网络恢复、App 启动和每 5 秒定时检查都会触发到期事件补传。
- 普通 Logger 事件本地最多保存 10000 条、最长保存 30 天；详细错误 Incident 最多保存 500 条、最长保存 30 天。

## OpenObserve Stream 建议

Stream：`app_events`

- 精确索引：`record_type`、`incident_id`、`event_code`、`merchant_id`、`machine_id`、`severity`、`app_version`、`platform`
- 全文索引：`message`、`error`
- 保留周期：初期 90 天
- 不要对 `breadcrumbs` 和 `stack_trace` 建立精确索引
