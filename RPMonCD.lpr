{=================================================================
This code come WITHOUT ANY WARRANTY
It under the terms of the latest version Waqf Public License as
published by Ojuba.org.
Written for Linux arab Community
www.linuxac.org
=================================================================}
program RPMonCD;

{$mode objfpc}{$H+}

uses
{$DEFINE UseCThreads}
{$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  RPMunit,
  unitAbout,
  LCLType,
  SysUtils { you can add units after this };

{$R *.res}

begin
  Application.Initialize;
  if GetEnvironmentVariable('USER') <> 'root' then
  begin
    Application.MessageBox('Some operation require root privélege, Please run this Application as root', 'Warning', MB_ICONWARNING);
    Application.Terminate;
  end;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.
