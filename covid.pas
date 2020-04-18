unit covid;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Graphics, Controls;

type

  // Сосотояние единицы популяции
  tStatus = (sick {Болеет}, healthy {Здоров}, recovered {Выздоровел и имеет иммунитет});

  { tVirus - класс единицы популяции, например, человек или животное}

  tVirus = class
    private
      x, y, vx, vy:Real; // Координаты и скорость x и y
      rad:Integer; // Радиус круга на изображении
      sts:tStatus; // Состояние единицы популяции
      time, _time_sick, _time_recovered:Integer;// Время, время болезни, время иммунитета

      function GetColor:TColor;// Возвращает цвет в зависимости от состояния
    public
      // Координата x
      property x_value:Real read x;
      // Координата y
      property y_value:Real read y;
      // Цвет
      property Color:TColor read GetColor;
      // Состояние
      property Status:tStatus read sts write sts;
      // Радиус
      property Radius:Integer read rad write rad;
      // Время иммунитета
      property TimeRecovered:Integer read _time_recovered write _time_recovered;
      // Время болезни
      property TimeSick:Integer read _time_sick write _time_sick;

      // Расчет координат объекта на сцене
      function GetCoord(width, height:Integer):TPoint;
      // Выполняет один временной шаг
      procedure OneStep(dt:Real);
      // Отрисовка объекта на сцене
      procedure Draw(cv: TCanvas; width, height: Integer);

      // конструктор и деструктор
      constructor Create(x0, y0, vx0, vy0:Real; s:tStatus; R:Integer=4;
        time_sick:Integer=200; time_recovered:integer=300);
      destructor Destroy; override;
  end;

implementation

{ tVirus }

procedure tVirus.Draw(cv: TCanvas; width, height: Integer);
var p:TPoint;
begin
     p:=GetCoord(width, height);

     cv.Pen.Color:=Color;
     cv.Pen.Style:=psSolid;
     cv.Brush.Color:=Color;
     cv.Brush.Style:=bsSolid;

     cv.Ellipse(p.x-rad, p.y-rad, p.x+rad, p.y+rad);
end;

function tVirus.GetColor:TColor;
begin
  case sts of
       tStatus.sick: Result:=clRed;
       tStatus.recovered: Result:=clBlue;
       tStatus.healthy: Result:=clGreen
       else
         Result:=clBlack;
  end;
end;

procedure tVirus.OneStep(dt:Real);
begin
  x:=x+vx*dt;
  y:=y+vy*dt;
  if (x<=0) or (x>=1.0) then vx:=-vx;
  if (y<=0) or (y>=1.0) then vy:=-vy;

  if sts=tStatus.sick then
  begin
    inc(time);
    if time>_time_sick then
    begin
      time:=0;
      sts:=tStatus.recovered;
    end;
  end;

  if sts=tStatus.recovered then
  begin
    inc(time);
    if time > _time_recovered then
    begin
      time:=0;
      sts:=tStatus.healthy;
    end;
  end;
end;

function tVirus.GetCoord(width, height:Integer):TPoint;
begin
  Result.x:=round(width * x);
  Result.y:=round(height * y);
end;

constructor tVirus.Create(x0, y0, vx0, vy0:Real; s:tStatus; R:Integer;
  time_sick:Integer=200; time_recovered:integer=300);
begin
   x:=x0;
   y:=y0;
   vx:=vx0;
   vy:=vy0;
   sts:=s;
   rad:=R;
   time:=0;
   _time_sick:= time_sick;
   _time_recovered:=time_recovered;
end;

destructor tVirus.Destroy;
begin
  inherited Destroy;
end;

end.

