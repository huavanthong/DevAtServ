; Script generated by the Inno Setup Script Wizard.
;
; Online Help: http://www.jrsoftware.org/ishelp/
;
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!
;
#ifndef SETUPVersion
   #define SETUPVersion "0.1.4.0"
#endif
#pragma message "SETUPVersion is : " + SETUPVersion
;Change History

#define MyAppName "DevAtServ (Device Automation Services)"

;Commandline argument 
;iscc /DDevAtServVersion=version /ITrackService=URL
;allows to set a DevAtServ- and Setup version 
;If nothing is provided, then use an empty string. The resulting
;installer will be called DevAtServ_setup__.exe in this case
;otherwise it is called   DevAtServ_setup_DevAtServVersion.exe
#ifndef DevAtServVersion
   #define DevAtServVersion ""
#endif
#pragma message "DevAtServVersion is   : " + DevAtServVersion

#ifdef ITrackService
   #define DoInstallTracking 
   #define InstallTrackingService StringChange(ITrackService,"\","/")
   #pragma message "ITrackService is: " + InstallTrackingService
#else
   #pragma message "ITrackService is: not defined"
#endif

#define MyAppVersion "DevAtServ " + DevAtServVersion + " (Installer " + SETUPVersion + ")"
#define MyAppFileName "DevAtServ_setup_" + DevAtServVersion
#define MyAppPublisher "Robert Bosch GmbH"

[Setup]
AppID={{1839778D-5111-4F6C-8ECE-94979F6477FB}}
AppName=DevAtServ
AppVersion=0.1.0.0
AppPublisher={#MyAppPublisher}
DefaultDirName={sd}\Program Files\DevAtServ
DefaultGroupName=DevAtServ
OutputBaseFilename={#MyAppFileName}
Compression=lzma
SolidCompression=yes
AppCopyright=Robert Bosch Car Multimedia GmbH
AppVerName={#MyAppVersion}
RestartIfNeededByRun=false
PrivilegesRequired=admin
ShowLanguageDialog=no
OutputDir=..\..\


[Files]
; Add any files your application needs here.
; ############### DevAtServ Services ###############
Source: ..\devatserv\bin\*; DestDir: "{app}\bin"; Flags: ignoreversion onlyifdoesntexist uninsneveruninstall; Permissions: users-full;
Source: ..\devatserv\share\applications\*; DestDir: "{app}\share\applications"; Flags: ignoreversion onlyifdoesntexist uninsneveruninstall; Permissions: users-full;
Source: ..\devatserv\share\storage\*; DestDir: "{app}\share\storage"; Flags: ignoreversion onlyifdoesntexist uninsneveruninstall; Permissions: users-full;
Source: ..\devatserv\share\start-services\docker-compose.yml; DestDir: "{app}\share\start-services"; Flags: ignoreversion onlyifdoesntexist uninsneveruninstall; Permissions: users-full;
Source: ..\devatserv\share\docker\DockerDesktopInstaller.exe; DestDir: "{app}\share\docker"; Flags: ignoreversion; Permissions: users-full;

; ############### DevAtServ'GUI ###############
Source: ..\devatserv\share\GUI\*; DestDir: "{app}\share\GUI"; Flags: ignoreversion

[Icons]
; Start Menu
Name: "{group}\DevAtServ"; Filename: "{app}\bin\start-devatserv.bat"; IconFilename: "{app}\share\applications\devatserv.ico"; Comment: "Start DevAtServ App"
Name: "{group}\DevAtServ's GUI"; Filename: {app}\share\GUI\DevAtServGUISetup1.0.0.exe;

[Run]
; Check if Docker is installed and run a script to load and run Docker images
Filename: "{app}\share\docker\DockerDesktopInstaller.exe"; WorkingDir: {app}; Description: "Install Docker Desktop"; Flags: postinstall skipifsilent runminimized

[Code]
const
  DockerExecutable = 'C:\Program Files\Docker\Docker\Docker Desktop.exe';

procedure RunOtherInstaller;
var
  ResultCode: Integer;
begin
  if not Exec(ExpandConstant('{app}\share\docker\DockerDesktopInstaller.exe'), '', '', SW_SHOWNORMAL,
    ewWaitUntilTerminated, ResultCode)
  then
    MsgBox('Other installer failed to run!' + #13#10 +
      SysErrorMessage(ResultCode), mbError, MB_OK);
end;

function IsDockerInstalled(): Boolean;
begin
  Result := FileExists(DockerExecutable);
  if not Result then
  begin
    MsgBox('Docker Desktop is not installed. Installing Docker Desktop now...', mbInformation, MB_OK);
    RunOtherInstaller;
    Result := FileExists(DockerExecutable);
    if not Result then
    begin
      MsgBox('Docker Desktop installation failed or was not detected.', mbError, MB_OK);
      WizardForm.Close;
    end;
  end
  else
  begin
    Result := True;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    if not IsDockerInstalled() then
    begin
      MsgBox('Docker Desktop installation is required to continue with this setup.', mbError, MB_OK);
    end;
  end;
end;

[UninstallRun]
; Remove all services in DevAtServ
Filename: "{app}\bin\stop-devatserv.bat"; Flags: runhidden

[UninstallDelete]
Name: {app}\bin\*; Type: filesandordirs;
Name: {app}\share\applications\*; Type: filesandordirs;
Name: {app}\share\start-services\*; Type: filesandordirs;
Name: {app}\share\storage\*; Type: filesandordirs;
Name: {app}\share\docker\*; Type: filesandordirs;

[InstallDelete]
Name: {app}\bin\*; Type: filesandordirs;
Name: {app}\share\applications\*; Type: filesandordirs;
Name: {app}\share\start-services\*; Type: filesandordirs;
Name: {app}\share\storage\*; Type: filesandordirs;