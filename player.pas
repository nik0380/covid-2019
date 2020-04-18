unit player;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, population, covid, Graphics;

type

  { TPlayer }

  TPlayer = class
    private
      // Координаты игрока
      x,y,w,h,dx:Real;
      // Ссылка на популяцию
      viruses:TPopulation;

      // Проверка инфицирования
      function CheckForInfection:Boolean;
      // Расчет координат на сцене для отрисовки
      function GetCoords(width:Integer; height:Integer):TRect;
    public
      // True - если игрок инфицирован, иначе - False
      property IsInfected:Boolean read CheckForInfection;

      // Рисуем игрока
      procedure Draw(cv:TCanvas; width:Integer; height:Integer);
      // Шаг влево и в право
      procedure MoveLeft;
      procedure MoveRight;

      // Конструктор и деструктор
      constructor Create(virs:TPopulation);
      destructor Destroy; override;
  end;

implementation

{ TPlayer }

function TPlayer.CheckForInfection: Boolean;
var i:Integer;
    xv,yv:Real;
    v:tVirus;
begin

     Result:=False;

     for i:=0 to viruses.Count-1 do
     begin
       v:=viruses.Virus[i];
       if v.Status=tStatus.sick then
       begin
         xv:=v.x_value;
         yv:=v.y_value;
         if ((xv>=x) and(xv<=(x+w))) and ((yv>y) and (yv<(y+h))) then
         begin
           Result:=True;
           break;
         end;
       end;
     end;
end;

function TPlayer.GetCoords(width:Integer; height:Integer):TRect;
begin
  Result.Left:=round(x*width);
  Result.Top:=round(y*height);
  Result.Right:=round((x+w) * width);
  Result.Bottom:=round((y+h) * height);
end;

procedure TPlayer.Draw(cv: TCanvas; width: Integer; height: Integer);
begin
  cv.Pen.Style:=psSolid;
  cv.Pen.Color:=clBlue;
  cv.Brush.Style:=bsSolid;
  cv.Brush.Color:=clGreen;
  cv.Rectangle(GetCoords(width, height));
end;

procedure TPlayer.MoveLeft;
begin
     x:=x-dx;
     if x<0 then x:=0;
end;

procedure TPlayer.MoveRight;
begin
     x:=x+dx;
     if x>(1-w) then x:=1-w;
end;

constructor TPlayer.Create(virs: TPopulation);
begin
  w:=0.1;
  h:=0.05;
  x:=Random*(1-w);
  y:= 1-h*1.01;
  dx:=w*0.1;

  viruses:=virs;
end;

destructor TPlayer.Destroy;
begin
  inherited Destroy;
end;

end.

