unit settingscv;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls;

type

  { TSettingsForm }

  TSettingsForm = class(TForm)
    bGo: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    tbCount: TTrackBar;
    tbSick: TTrackBar;
    tbTimeStayAlive: TTrackBar;
    tbTimeSick: TTrackBar;
    tbTimeRecovered: TTrackBar;
    procedure bGoClick(Sender: TObject);
  private

  public

  end;


implementation

{$R *.lfm}

{ TSettingsForm }

procedure TSettingsForm.bGoClick(Sender: TObject);
begin
  self.ModalResult:=mrOK;
end;

end.

