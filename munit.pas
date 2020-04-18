unit munit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Scene,
  LCLType {коды клавиатуры}, settingscv {Окно настроек}, math;

type

  { TMainForm }

  TMainForm = class(TForm)
    GameTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure GameTimerTimer(Sender: TObject);
  private
    scene:TScene; // Сцена игры
    settings:TSettingsForm; // окно начальных настроек

    procedure StartGame;// Начало игры
    procedure EndGame; // Конец игры
  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

// Обработка событий таймера
procedure TMainForm.GameTimerTimer(Sender: TObject);
begin
     if scene<>nil then
     begin
          scene.OneStep(0.1);
          scene.Draw;
          if scene.GameStatus<>tGameStatus.Game then EndGame;
     end
     else
     begin
       StartGame;
     end;
end;

procedure TMainForm.StartGame;
begin

  GameTimer.Enabled:=False;

  if settings.ShowModal = mrOK then
  begin

    scene:=TScene.Create(
     self,
     settings.tbCount.Position,
     settings.tbSick.Position,
     4,
     settings.tbTimeSick.Position,
     settings.tbTimeRecovered.Position,
     settings.tbTimeStayAlive.Position
    );

    GameTimer.Enabled:=True;
  end
  else
      Close;
end;

procedure TMainForm.EndGame;
begin

     GameTimer.Enabled:=False;

     if scene.GameStatus = tGameStatus.Loss then
     begin
          ShowMessage('ВЫ ПРОИГРАЛИ!!!');
     end;

     if scene.GameStatus = tGameStatus.Win then
     begin
          ShowMessage('ПОБЕДА!!!');
     end;

     scene.Free;
     scene:=nil;
     GameTimer.Enabled:=True;
end;

// Инициализация игры
procedure TMainForm.FormCreate(Sender: TObject);
var scr:TScreen;
    size:Integer;
begin
     scr:=TScreen.Create(self);
     size:=round(min(scr.DesktopWidth*0.9, scr.DesktopHeight*0.9));
     ClientWidth:=size;
     ClientHeight:=size;
     scene:=nil;
     settings:=TSettingsForm.Create(self);
end;

// Обработка нажатия на клавишу
procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if scene<>nil then
  begin
    if Key = VK_LEFT then scene.MoveLeft;
    if Key = VK_RIGHT then scene.MoveRight;
  end;
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  if scene<>nil then
     scene.Draw;
end;

procedure TMainForm.FormResize(Sender: TObject);
var size:Integer;
begin
     size:=min(ClientWidth, ClientHeight);
     ClientWidth:=size;
     ClientHeight:=size;
end;

end.

