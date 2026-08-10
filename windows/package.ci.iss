; CI Inno Setup script adapted from local origin_local_build.iss
; __CI_VERSION__ token will be replaced by workflow.
; Keep functionality parity with local script: upgrade detection, cert install,
; OPOS setup on first install, uninstall cleanup.

#define MyAppName "Foodorder"
#define AppName "券売君"
#define MyAppVersion "__CI_VERSION__"
#define MyAppPublisher "SmartWe Company, Inc."
#define MyAppURL "https://smartwe.co.jp/"
#define MyAppExeName "foodorder.exe"
#define MyAppAssocName MyAppName + " File"
#define MyAppAssocExt ".myp"
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt
; 清理的 AppData 子路径（请按实际路径调整）
#define AppDataSubPath "com.fanxing\\foodorder"

; Paths (SourcePath points to script directory at compile time)
#define RepoRoot SourcePath
#define BuildOut RepoRoot + "build\\windows\\x64\\runner\\Release"
#define ExtraSetup RepoRoot + "windows\\Setup"

[Setup]
; Return the same effective AppId as the installers already shipped to
; customers, without using the legacy "{{GUID}" syntax rejected by CI.
AppId={code:GetCanonicalAppId}
AppName={#AppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
; Required when AppId uses a scripted {code:...} constant. This only disables
; restoring the previous wizard language; upgrade identity remains unchanged.
UsePreviousLanguage=no
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
ChangesAssociations=yes
DisableProgramGroupPage=yes
OutputDir=output
OutputBaseFilename=smartwe_ticket_machine_{#MyAppVersion}
SetupIconFile=windows\icons\a5nhg-kcvff-001.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\\Japanese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; Check: IsNotUpgrade

[Files]
; Core executable and runtime DLLs
Source: "{#BuildOut}\\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildOut}\\appset_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildOut}\\audioplayers_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildOut}\\cash_changer_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildOut}\\charset_converter_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildOut}\\connectivity_plus_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildOut}\\dynamic_color_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildOut}\\flutter_plugin_msprinter_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildOut}\\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildOut}\\permission_handler_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildOut}\\r_get_ip_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
; Data directory (recursive)
Source: "{#BuildOut}\\data\\*"; DestDir: "{app}\\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; Extra setup scripts/resources
Source: "{#ExtraSetup}\\*"; DestDir: "{app}\\Setup"; Flags: ignoreversion recursesubdirs createallsubdirs

[Registry]
Root: HKA; Subkey: "Software\\Classes\\{#MyAppAssocExt}\\OpenWithProgids"; ValueType: string; ValueName: "{#MyAppAssocKey}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\\Classes\\{#MyAppAssocKey}"; ValueType: string; ValueName: ""; ValueData: "{#MyAppAssocName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\\Classes\\{#MyAppAssocKey}\\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\\Classes\\{#MyAppAssocKey}\\shell\\open\\command"; ValueType: string; ValueName: ""; ValueData: """{app}\\{#MyAppExeName}"" ""%1"""
Root: HKA; Subkey: "Software\\Classes\\Applications\\{#MyAppExeName}\\SupportedTypes"; ValueType: string; ValueName: ".myp"; ValueData: ""

[Icons]
Name: "{group}\\券売君"; Filename: "{app}\\{#MyAppExeName}"
Name: "{userdesktop}\\券売君"; Filename: "{app}\\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; Generate Windows root cert bundle (for runtime HTTPS trust if needed)
Filename: "cmd"; Parameters: "/c certutil -generateSSTFromWU roots.sst"; WorkingDir: "{app}"; Flags: runhidden waituntilterminated
; Import bundle into root store (requires admin)
Filename: "cmd"; Parameters: "/c certutil -addstore -f root roots.sst"; WorkingDir: "{app}"; Flags: runhidden waituntilterminated
; One-time peripheral / OPOS setup scripts on fresh install only
Filename: "{app}\\Setup\\OPOSSetup.bat"; Flags: shellexec; Check: IsNotUpgrade
Filename: "{app}\\Setup\\OPOSSetup.exe"; Flags: nowait postinstall runascurrentuser; Check: IsNotUpgrade
; Optional: auto launch application after install (uncomment if desired)
; Filename: "{app}\\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
; 同时删除当前用户的 AppData 数据
Type: filesandordirs; Name: "{userappdata}\{#AppDataSubPath}"
Type: filesandordirs; Name: "{localappdata}\{#AppDataSubPath}"
; 如有共享数据可启用
; Type: filesandordirs; Name: "{commonappdata}\{#AppDataSubPath}"

[Code]
var
  IsUpgrade: Boolean;

function GetCanonicalAppId(Param: String): String;
begin
  Result := '{E254136A-A120-4B9F-B394-F712FCC5D560}';
end;

function InitializeSetup(): Boolean;
begin
  // 检查注册表中是否存在升级标志
  IsUpgrade := RegKeyExists(HKEY_CURRENT_USER, 'Software\{#MyAppName}');
  Result := True;
end;

function IsNotUpgrade: Boolean;
begin
  Result := not IsUpgrade;
end;


procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // 安装完成后,将升级标志写入注册表
    RegWriteStringValue(HKEY_CURRENT_USER, 'Software\{#MyAppName}', 'Installed', 'Yes');
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ResultCode: Integer;
begin
  case CurUninstallStep of
    usUninstall:
      begin
        if Exec(ExpandConstant('{app}\Setup\Cleanup.bat'), '', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
        begin
          // 批处理文件执行成功
        end
        else
        begin
          // 批处理文件执行失败
          MsgBox('Failed to execute uninstall script', mbError, MB_OK);
        end;

        // 删除当前用户 AppData（Roaming 与 Local）
        DelTree(ExpandConstant('{userappdata}\{#AppDataSubPath}'), True, True, True);
        DelTree(ExpandConstant('{localappdata}\{#AppDataSubPath}'), True, True, True);

        // 删除注册表项
        if RegKeyExists(HKEY_CURRENT_USER, 'Software\{#MyAppName}') then
        begin
          RegDeleteKeyIncludingSubkeys(HKEY_CURRENT_USER, 'Software\{#MyAppName}');
        end;
      end;
    usPostUninstall:
      begin
        // 直接删除安装文件夹
        DelTree(ExpandConstant('{app}'), True, True, True);
      end;
  end;
end;
