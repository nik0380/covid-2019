unit Scene;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, population, player, Forms;

type
    // Состояния игры
    tGameStatus = (Win {Победа}, Loss {Проигрыш}, Game {Игра продолжается});

{ TScene - класс игровой сцены}

TScene = class
  private
    bmp:TBitmap;// Графический буфер для формирования кадра изображения
    viruses:TPopulation;// Популяция
    view:TForm;// окно вывода графической информации
    player:TPlayer;// объект игрока
    start_time:LongInt;// Время запуска игры
    stay_alive_time:Integer;// Время выживария (минуты)

    procedure DrawVirus;// Рисуем популяцию
    procedure DrawPanel;// Рисуем панель информации
    procedure DrawPlayer;// Рисуем игрока
    procedure DrawHint;// Рисуем подсказку
    function _check_game:tGameStatus;// Проверяем условия окончания игры

  public
    // Возвращает состояние игры
    property GameStatus:tGameStatus read _check_game;
    // Рисует игровое поле
    procedure Draw;
    // Один временной шаг
    procedure OneStep(dt:Real=0.01);
    // Игрок пошел налево
    procedure MoveLeft;
    // Игрок пошел направо
    procedure MoveRight;

    // Конструктор
    constructor Create(wnd:TForm; n:Integer=10;n_infected:Integer=1;
      R:Integer=4; time_sick:Integer=200; time_recovered:integer=300;
      time_stay_alive:Integer=3);
    // Деструктор
    destructor Destroy; override;
  end;


implementation

{ TScene }

procedure TScene.DrawVirus;
begin
   viruses.Draw(bmp.Canvas, bmp.Width, bmp.Height);
end;

procedure TScene.DrawPlayer;
begin
  player.Draw(bmp.Canvas, bmp.Width, bmp.Height);
end;

procedure TScene.DrawHint;
const text1 = 'Управление курсором: <- | ->';
      text2 = 'Избегайте красных шаров!';
var x,y,w,h:Integer;
begin
  // Показываем подсказку 5 секунд
  if GetTickCount64-start_time < 5000 then
  begin
       with bmp.Canvas do
       begin
           Font.Color:=clPurple;
           Font.Size:=20;
           w:=TextWidth(text1);
           h:=TextHeight(text1);
           x:=(bmp.Width - w) div 2;
           y:=(bmp.Height - h) div 2;
           TextOut(x,y-h, text1);

           w:=TextWidth(text2);
           h:=TextHeight(text2);
           x:=(bmp.Width - w) div 2;
           y:=(bmp.Height - h) div 2;

           TextOut(x,y + h div 2, text2);
       end;
  end;
end;

function TScene._check_game: tGameStatus;
var t:Real;
begin

  Result:=tGameStatus.Game;

  // Вы заразились - проигрыш!
  if player.IsInfected then
  begin
    Result:=tGameStatus.Loss;
    exit;
  end;

  // Все здоровы - победа!
  if (viruses.Healthy + viruses.Recovered) = viruses.Count then
  begin
    Result:=tGameStatus.Win;
    exit;
  end;

  // GetTickCount - возвращает время в миллисекундах, переводим в минуты
  t:=(GetTickCount64 - start_time)/1000/60;

  // Вы продержались заданное время - победа!
  if t > stay_alive_time then
  begin
    Result:=tGameStatus.Win;
    exit;
  end;

end;

procedure TScene.DrawPanel;
var h,w:Integer;
    s1,s2,s3,s4:String;
    t, m, sec:Integer;
begin
   t:=round((GetTickCount64 - start_time) / 1000.0);
   m:= t div 60;
   sec:= t mod 60;

   s1:=Format('Заражен: %d', [viruses.Sick]);
   s2:=Format('Иммунитет: %d', [viruses.Recovered]);
   s3:=Format('Здоровы: %d', [viruses.Healthy]);
   s4:=Format('Время: %2d:%2d',[m, sec]);

   with bmp.Canvas do
   begin
        Brush.Style:=bsClear;
        Pen.Style:=psSolid;
        Pen.Color:=clYellow;
        Font.Size:=12;
        h:=TextHeight(s1);
        w:=TextWidth(s2);
        Rectangle(0,0,w,4*h);
        Font.Color:=clRed;
        TextOut(0,0, s1);
        Font.Color:=clBlue;
        TextOut(0,h, s2);
        Font.Color:=clGreen;
        TextOut(0,2*h, s3);
        Font.Color:=clGray;
        TextOut(0,3*h, s4);
   end;
end;

procedure TScene.Draw;
begin

   if bmp.Width<>view.ClientWidth then bmp.Width:=view.ClientWidth;
   if bmp.Height<>view.ClientHeight then bmp.Height:=view.ClientHeight;

   with bmp.Canvas do
   begin
        Pen.Color:=clBlack;
        Pen.Style:=psSolid;
        Brush.Color:=clWhite;
        Brush.Style:=bsSolid;
        Rectangle(0,0, bmp.Width, bmp.Height);
   end;

   DrawPlayer;
   DrawVirus;
   DrawPanel;
   DrawHint;

   view.Canvas.CopyRect(view.ClientRect, bmp.Canvas, view.ClientRect);
end;

procedure TScene.OneStep(dt: Real);
begin
     viruses.OnStep(dt);
end;

procedure TScene.MoveLeft;
begin
  player.MoveLeft;
end;

procedure TScene.MoveRight;
begin
  player.MoveRight;
end;

constructor TScene.Create(wnd: TForm; n: Integer; n_infected:Integer=1;
  R:Integer=4; time_sick:Integer=200; time_recovered:integer=300;
  time_stay_alive:Integer=3);
begin
     view:=wnd;
     viruses:=TPopulation.Create(n, n_infected,R, time_sick, time_recovered);
     player:=TPlayer.Create(viruses);
     bmp:=TBitmap.Create;
     bmp.Width:=view.ClientWidth;
     bmp.Height:=view.ClientHeight;
     stay_alive_time:=time_stay_alive;
     start_time:=GetTickCount64;
end;

destructor TScene.Destroy;
begin

  viruses.Free;
  bmp.Free;
  player.Free;

  inherited Destroy;
end;

end.

