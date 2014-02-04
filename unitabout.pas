{=================================================================
This code come WITHOUT ANY WARRANTY
It under the terms of the latest version Waqf Public License as
published by Ojuba.org.
Written for Linux arab Community
www.linuxac.org
=================================================================}
unit unitAbout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls, Buttons;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    BitBtn1: TBitBtn;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.lfm}

{ TfrmAbout }




procedure TfrmAbout.BitBtn1Click(Sender: TObject);
begin
  close;
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
begin

end;

end.

