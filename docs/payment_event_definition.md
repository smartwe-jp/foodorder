# 交易事件定义（第一版）

## 关联与统计规则

- 一次进入 `SettlementController` 生成一个 `flow_id`。
- 同一笔交易的支付、上报、订单完成和打印派发都使用同一个 `flow_id`。
- 每个 `flow_id` 最多产生一个终态事件：
  - `PAYMENT_FLOW_SUCCEEDED`
  - `PAYMENT_FLOW_FAILED`
  - `PAYMENT_FLOW_CANCELLED`
- 成功率只统计 `PAYMENT_FLOW_SUCCEEDED` 和 `PAYMENT_FLOW_FAILED`，主动取消不进入分母。
- 统计交易数时使用 `COUNT(DISTINCT flow_id)`，避免断网重传造成重复计数。

## 公共字段

| 字段 | 说明 |
| --- | --- |
| `event_code` | 稳定事件代码，查询和告警使用 |
| `flow_id` | 单次完整交易 ID |
| `order_id` | 订单 ID |
| `merchant_id` | 商户 ID |
| `machine_id` | 机器 ID |
| `payment_method` | `cash`、`qr`、`credit_card` 等稳定名称 |
| `payment_method_code` | 现有系统支付方式代码 |
| `event_status` | `started`、`succeeded`、`failed`、`cancelled`、`accepted` |
| `stage` | 当前交易阶段 |
| `attempt` | 当前操作尝试次数 |
| `duration_ms` | 从该阶段开始到结束的耗时 |
| `failure_type` | 统一失败分类 |
| `result_code` | 设备或服务端结果代码，不保存完整支付报文 |

## 失败分类

- `network_error`
- `timeout`
- `device_unavailable`
- `device_rejected`
- `backend_rejected`
- `invalid_response`
- `print_error`
- `unknown`

## 事件

### 交易终态

- `PAYMENT_FLOW_STARTED`
- `PAYMENT_FLOW_SUCCEEDED`
- `PAYMENT_FLOW_FAILED`
- `PAYMENT_CANCEL_REQUESTED`
- `PAYMENT_CANCEL_FAILED`
- `PAYMENT_FLOW_CANCELLED`

### 现金

- `CASH_DEVICE_OPEN_STARTED`
- `CASH_DEVICE_OPEN_SUCCEEDED`
- `CASH_DEVICE_OPEN_FAILED`
- `CASH_DEPOSIT_STOP_STARTED`
- `CASH_DEPOSIT_STOP_SUCCEEDED`
- `CASH_DEPOSIT_STOP_FAILED`
- `CASH_CHANGE_STARTED`
- `CASH_CHANGE_COMMAND_ACCEPTED`
- `CASH_CHANGE_SUCCEEDED`
- `CASH_CHANGE_FAILED`
- `CASH_TRANSACTION_CLOSE_STARTED`
- `CASH_TRANSACTION_CLOSE_SUCCEEDED`
- `CASH_TRANSACTION_CLOSE_FAILED`

`CASH_CHANGE_COMMAND_ACCEPTED` 只表示现金机接受出金命令；收到并核对实际出金币种和金额后，才记录 `CASH_CHANGE_SUCCEEDED`。

### 二维码

- `QR_PAYMENT_STARTED`
- `QR_PAYMENT_SUCCEEDED`
- `QR_PAYMENT_FAILED`
- `QR_PAYMENT_TIMEOUT`

### POS、信用卡和电子支付

- `POS_CONNECT_STARTED`
- `POS_CONNECT_SUCCEEDED`
- `POS_CONNECT_FAILED`
- `POS_CONNECT_TIMEOUT`
- `CARD_PAYMENT_STARTED`
- `CARD_PAYMENT_DEVICE_SUCCEEDED`
- `CARD_PAYMENT_FAILED`
- `CARD_PAYMENT_CANCELLED`
- `PAYMENT_REPORT_STARTED`
- `PAYMENT_REPORT_SUCCEEDED`
- `PAYMENT_REPORT_FAILED`

`CARD_PAYMENT_DEVICE_SUCCEEDED` 只代表支付设备处理成功。必须继续观察 `PAYMENT_REPORT_SUCCEEDED`，判断后台是否接受支付结果。

### 订单完成与打印

- `ORDER_FINALIZE_STARTED`
- `ORDER_FINALIZE_SUCCEEDED`
- `ORDER_FINALIZE_FAILED`
- `PRINT_STARTED`
- `PRINT_DISPATCHED`

`PRINT_DISPATCHED` 只表示打印任务已经交给打印模块，不代表纸张已经打印成功。物理打印机的 `PRINT_SUCCEEDED` 和 `PRINT_FAILED` 需要在打印确认模块中另外接入。

## 禁止上传

- 二维码原文和 `auth_code`
- POS 完整 `requestInfo`
- 完整 `paymentInfo`
- 卡号、顾客信息
- 完整打印内容和菜品明细
