{=================================================================
This code come WITHOUT ANY WARRANTY
It under the terms of the latest version Waqf Public License as
published by Ojuba.org.
Written for Linux arab Community
www.linuxac.org
=================================================================}
unit RPMunit;

{$mode objfpc}{$H+}
interface

uses
  {$DEFINE UseCThreads}
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, Menus, StdCtrls, Buttons, EditBtn, Unix, LCLType,
  unitAbout;

{Thread....}
type
  TMyThread = class(TThread)
  protected
    procedure Execute; override;
  public
    constructor Create(Susp: boolean);
  end;

type
  { TfrmMain }
  TfrmMain = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    btnRestoreYUMonCD: TBitBtn;
    btnCreateYUMonCD: TBitBtn;
    InstallRPM: TBitBtn;
    dirRPMS: TDirectoryEdit;
    destination: TDirectoryEdit;
    FileYUMonCD: TFileNameEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ProgressBar1: TProgressBar;
    ProgressBar2: TProgressBar;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure DeleteOldVersion(ListFiles: string);
    procedure btnCreateYUMonCDClick(Sender: TObject);
    procedure btnRestoreYUMonCDClick(Sender: TObject);
    procedure InstallRPMClick(Sender: TObject);


  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmMain: TfrmMain;
  txtFile: TextFile;
  list: TStringList;
  frmCreate, found_fedora: boolean;
  app, line, UserName, rpm, rpm1, filename, fileext: string;
  i: integer;
  ThreadTermined: boolean;

implementation

{$R *.lfm}

//Uitiltaire
{============================================================================}
{ fonction qui renvoie la sous chaine de caractère situè à gauche de la sous }
{ chaine substr                                                              }
{ ex: si substr = '\' et S= 'truc\tr\essai.exe' gauche renvoie truc           }
{============================================================================}
function gauche(substr: string; s: string): string;
begin
  Result := copy(s, 1, pos(substr, s) - 1);
end;

{============================================================================}
{Renvoie ce qui est à droite d'une sous chaine de caractères                 }
{ ex : Droite('aa', 'phidelsaacom') renvoie com                              }
{============================================================================}
function droite(substr: string; s: string): string;
begin
  if pos(substr, s) = 0 then
    Result := ''
  else
    Result := copy(s, pos(substr, s) + length(substr), length(s) - pos(substr, s) + length(substr));
end;

{============================================================================}
{ fonction qui renvoie la sous chaine de caractère situè à droite de la sous }
{ chaine substr située la plus à droite                                      }
{============================================================================}
function droiteDroite(substr: string; s: string): string;
begin
  repeat
    S := droite(substr, s);
  until pos(substr, s) = 0;
  Result := S;
end;

{=============================================================================
Count of lines
=============================================================================}
function linecount(filename: string): integer;
var
  f: textfile;
begin
  assignfile(f, filename);
  reset(f);
  Result := 0;
  while not EOF(f) do
  begin
    readln(f);
    Inc(Result);
  end;
  closefile(f);
  linecount := Result;
end;




//================================================Thread
{ Mythread }
constructor TMyThread.Create(Susp: boolean);
begin
  FreeOnTerminate := True;
  inherited Create(susp);
end;

procedure TMyThread.Execute;
begin
  fpSystem('rpm -i --force --nodeps /opt/yumoncd-repo/packages/*.rpm');
  ThreadTermined := True;
end;


//================================================Form
{ TfrmMain }
procedure TfrmMain.BitBtn1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.BitBtn2Click(Sender: TObject);
begin
  frmAbout.Show;
end;

procedure TfrmMain.DeleteOldVersion(ListFiles: string);
var
  firstlist, Lastlist: TStringList;
  i: integer;
  FileName: string;
  alow: boolean;
begin
  firstlist := TStringList.Create;
  Lastlist := TStringList.Create;
  firstlist.LoadFromFile(ListFiles);
  firstlist.Sort;
  for i := 0 to firstlist.Count - 1 do
  begin
    FileName := gauche('.', firstlist.Strings[i]);
    if (i + 1) <= (firstlist.Count - 1) then
      if FileName = gauche('.', firstlist.Strings[i + 1]) then
        Lastlist.Add(firstlist.Strings[i]);
  end;
  Progressbar1.Position := 0;
  Progressbar1.Max := lastlist.Count;
  Label3.Caption := 'Create a list of files ...';
  if MessageDlg('Do want you to remove the old rpm versions from your hardDisk?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    alow := True
  else
    alow := False;
  for i := 0 to lastlist.Count - 1 do
    try
      if alow then
      begin
        Label3.Caption := 'Deleting old versions of ' + ExtractFileName(Lastlist.Strings[i]) + '...';
        DeleteFile(Lastlist.Strings[i]);
      end;
      firstlist.Delete(firstlist.IndexOf(Lastlist.Strings[i]));
      Progressbar1.Position := Progressbar1.Position + 1;
      Application.ProcessMessages;
    except
      Continue;
    end;
  firstlist.SaveToFile(ListFiles);
  firstlist.Free;
  Lastlist.Free;
end;



procedure TfrmMain.btnCreateYUMonCDClick(Sender: TObject);
begin
  if destination.Directory = '' then
  begin
    Application.MessageBox('Select Destination directory', 'Error', MB_ICONERROR);
    exit;
  end;
  //create a temporair dir...
  filename := 'yumoncd-' + DateToStr(Now);
  if DirectoryExistsUTF8(GetUserDir + '/yumoncd') then
    DeleteDirectory(GetUserDir + '/yumoncd', False);
  mkdir(GetUserDir + '/yumoncd');
  mkdir(GetUserDir + '/yumoncd/packages');
  sleep(1000);
  //seach files...
  fpSystem('find ' + dirRPMS.Directory + ' -name  *.rpm* -exec echo {} \; >> ' + GetUserDir + '/yumoncd/rpms.txt');

  //delete old verion
  DeleteOldVersion(GetUserDir + '/yumoncd/rpms.txt');

  //set the progressbar max equal number of lines in the rpm.txt
  Progressbar1.Max := linecount(GetUserDir + '/yumoncd/rpms.txt');
  Progressbar1.Position := 0;

  //copy files to temporary directory
  Label3.Caption := 'Copy files to ~/yumoncd';
  sleep(1000);
  AssignFile(txtFile, GetUserDir + '/yumoncd/rpms.txt');
  reset(txtFile);
  while not EOF(txtFile) do
  begin
    ReadLn(txtFile, rpm);
    rpm1 := ExtractFileName(rpm);
    Label3.Caption := 'Copy ' + rpm1;
    CopyFile(rpm, GetUserDir + '/yumoncd/packages/' + rpm1);
    Progressbar1.Position := Progressbar1.Position + 1;
    Application.ProcessMessages;
  end;
  CloseFile(txtFile);
  //create iso file in home dir
  Label3.Caption := '';
  Label3.Caption := 'Create iso file in home dir ...';
  fpSystem('xterm -e genisoimage -r -o ' + destination.Directory + '/' + filename + '.iso ' + GetUserDir + '/yumoncd');

  DeleteDirectory(GetUserDir + '/yumoncd', False);  //cleaning
  Label3.Caption := 'YUMonCD ISO file is ready in ' + destination.Directory;
end;

procedure TfrmMain.btnRestoreYUMonCDClick(Sender: TObject);
begin
  if FileYUMonCD.FileName = '' then
    Application.MessageBox('Select a BackUp file', 'Error', MB_ICONERROR)
  else
  begin
    if DirectoryExistsUTF8(GetUserDir + '/yumoncd-mount') then
      fpSystem('umount ' + GetUserDir + '/yumoncd-mount && rm -rf ' + GetUserDir + '/yumoncd-mount');
    mkdir(GetUserDir + '/yumoncd-mount');

    fileext := droiteDroite('.', FileYUMonCD.FileName);
    if fileext <> 'iso' then
    begin
      Application.MessageBox('Invalide backup file', 'Error', MB_ICONERROR);
      FileYUMonCD.FileName := '';
      DeleteFile(GetUserDir + '/yumoncd-mount');
    end
    else
    begin
      fpSystem('mount -o loop ' + FileYUMonCD.FileName + ' ' + GetUserDir + '/yumoncd-mount');
      if not FileExists(GetUserDir + '/yumoncd-mount/rpms.txt') then
      begin
        Application.MessageBox('File Not Found !', 'Error', MB_ICONERROR);
        FileYUMonCD.FileName := '';
      end
      else
      begin
        // copy the repo to local dir /opt and add it to the yum system
        if DirectoryExistsUTF8('/opt/yumoncd-repo') then
          DeleteDirectory('/opt/yumoncd-repo', False);
        mkdir('/opt/yumoncd-repo');
        mkdir('/opt/yumoncd-repo/packages');
        Progressbar2.Max := linecount(GetUserDir + '/yumoncd-mount/rpms.txt');
        //set the progressbar max equal number of lines in the rpm.txt
        AssignFile(txtFile, GetUserDir + '/yumoncd-mount/rpms.txt');
        Reset(txtFile);
        while not EOF(txtFile) do
        begin
          ReadLn(txtFile, rpm);
          rpm1 := ExtractFileName(rpm);
          Label5.Caption := 'Copy : ' + rpm1;
          CopyFile(GetUserDir + '/yumoncd-mount/packages/' + rpm1, '/opt/yumoncd-repo/packages/' + rpm1);
          Progressbar2.Position := Progressbar2.Position + 1;
          Application.ProcessMessages;
        end;
        CloseFile(txtFile);
        fpSystem('createrepo /opt/yumoncd-repo');
        AssignFile(txtFile, '/etc/yum.repos.d/yumoncd.repo');
        Rewrite(txtFile);
        WriteLn(txtFile, '[yumoncd-repo]');
        WriteLn(txtFile, 'name=yumoncd');
        WriteLn(txtFile, 'failovermethod=priority');
        WriteLn(txtFile, 'baseurl=file:///opt/yumoncd-repo');
        WriteLn(txtFile, 'enabled=1');
        WriteLn(txtFile, 'gpgcheck=0');
        WriteLn(txtFile, 'cost=400');
        CloseFile(txtFile);
        if DirectoryExistsUTF8(GetUserDir + '/yumoncd-mount') then
          fpSystem('umount ' + GetUserDir + '/yumoncd-mount && rm -rf ' + GetUserDir + '/yumoncd-mount');
        Application.MessageBox('The local repo yumoncd-repo is ready , Please run "yum update" to check it', 'INFO', MB_ICONINFORMATION);
      end;
    end;
  end;
end;

procedure TfrmMain.InstallRPMClick(Sender: TObject);
var
  InstallThread: TMyThread;
begin
  if FileExists('/etc/yum.repos.d/yumoncd.repo') and DirectoryExistsUTF8('/opt/yumoncd-repo/packages')  then
  begin
    Label5.Caption := 'Instaling ...';
    ProgressBar2.Position := 0;
    ProgressBar2.Style := pbstMarquee;
    ThreadTermined := False;
    InstallThread := TMyThread.Create(False);
    while not ThreadTermined do
      Application.ProcessMessages;
    Label5.Caption := '';
    ProgressBar2.Position := 0;
    ProgressBar2.Style := pbstNormal;
    Application.MessageBox('Installation Terminated with successfully', 'Info', MB_ICONINFORMATION);
  end
  else
    Application.MessageBox('Restore before installation', 'Warning', MB_ICONWARNING);
end;




end.
