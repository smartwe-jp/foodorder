; CI Inno Setup script adapted from local package.iss
; Use ISCC to build installer in GitHub Actions.
; Version token __CI_VERSION__ will be replaced by workflow step.

#define MyAppName "Foodorder"
#define AppName "券売君"
#define MyAppVersion "__CI_VERSION__"
#define MyAppPublisher "SmartWe Company, Inc."
#define MyAppURL "https://smartwe.co.jp/"
#define MyAppExeName "foodorder.exe"
#define MyAppAssocName MyAppName + " File"
#define MyAppAssocExt ".myp"
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt

; Paths relative to repo root (SourcePath() is directory of this script at compile time)
#define RepoRoot SourcePath() + "..\\"
#define BuildOut RepoRoot + "build\\windows\\x64\\runner\\Release"
#define ExtraSetup RepoRoot + "windows\\Setup"

[Setup]
AppId={{E254136A-A120-4B9F-B394-F712FCC5D560}}
AppName={#AppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
ChangesAssociations=yes
DisableProgramGroupPage=yes
OutputDir=output
OutputBaseFilename=smartwe_ticket_machine_{#MyAppVersion}
; Place an icon file at windows\icons\a5nhg-kcvff-001.ico or adjust below
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
; Data directory (recursively)
Source: "{#BuildOut}\\data\\*"; DestDir: "{app}\\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; Extra setup scripts/resources (must be added to repo under windows/Setup)
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
Filename: "cmd"; Parameters: "/c certutil -generateSSTFromWU roots.sst"; WorkingDir: "{app}"; Flags: runhidden waituntilterminated
Filename: "cmd"; Parameters: "/c certutil -addstore -f root roots.sst"; WorkingDir: "{app}"; Flags: runhidden waituntilterminated
Filename: "{app}\\Setup\\OPOSSetup.bat"; Flags: shellexec; Check: IsNotUpgrade
Filename: "{app}\\Setup\\OPOSSetup.exe"; Flags: nowait postinstall runascurrentuser; Check: IsNotUpgrade

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
var
  IsUpgrade: Boolean;

function InitializeSetup(): Boolean;
begin
  IsUpgrade := RegKeyExists(HKEY_CURRENT_USER, 'Software\\{#MyAppName}');
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
    RegWriteStringValue(HKEY_CURRENT_USER, 'Software\\{#MyAppName}', 'Installed', 'Yes');
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ResultCode: Integer;
begin
  case CurUninstallStep of
    usUninstall:
      begin
        if Exec(ExpandConstant('{app}\\Setup\\Cleanup.bat'), '', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
        begin
        end
        else
        begin
          MsgBox('Failed to execute uninstall script', mbError, MB_OK);
        end;
        if RegKeyExists(HKEY_CURRENT_USER, 'Software\\{#MyAppName}') then
        begin
          RegDeleteKeyIncludingSubkeys(HKEY_CURRENT_USER, 'Software\\{#MyAppName}');
        end;
      end;
    usPostUninstall:
      begin
        DelTree(ExpandConstant('{app}'), True, True, True);
      end;
  end;
end;
