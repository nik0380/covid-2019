unit population;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, covid;

type

  { TPopulation - популяция}

  TPopulation = class

  private
    // Массив популяции
    viruses:array of tVirus;

    function get_count:Integer; // Численность популяции
    procedure set_virus(i:Integer; v:tVirus); // установить i-й элемент популяции
    function get_virus(i:Integer):tVirus;// получить i-й элемент популяции
    function getSick:Integer;// Число больных
    function getHealthy:Integer;// Число здоровых
    function getRecovered:Integer;// Число с иммунитетом
    // Число элементов с заданным статусом
    function getStatusCount(s:tStatus):Integer;
    // Проверяет если рядом с v есть объекты, то они зазажаются
    procedure Infection(v:tVirus);
  public
    // Численность популяции
    property Count:Integer read get_count;
    // Обращение к элементу популяции по индексу
    property Virus[i:Integer]:tVirus read get_virus write set_virus;
    // Число болеющих
    property Sick:Integer read getSick;
    // Число здоровых
    property Healthy:Integer read getHealthy;
    // Число с иммунитетом
    property Recovered:Integer read getRecovered;

    // Рисуем популяцию
    procedure Draw(cv:TCanvas; width, height:Integer);
    // Выполняем один временной шаг для популяции
    procedure OnStep(dt:Real);

    // Конструктор и деструктор
    constructor Create(n:Integer=10; n_infected:Integer=1;
      R:Integer=4; time_sick:Integer=200; time_recovered:integer=300);
    destructor Destroy; override;
  end;

implementation

{ TPopulation }

function TPopulation.getStatusCount(s:tStatus):Integer;
var i,n:Integer;
begin
     n:=0;

     for i:=0 to High(viruses) do
         if viruses[i].Status = s then inc(n);

     Result:=n;
end;

function TPopulation.getSick:Integer;
begin
     Result:=getStatusCount(tStatus.sick);
end;

function TPopulation.getHealthy:Integer;
begin
     Result:=getStatusCount(tStatus.healthy);
end;

function TPopulation.getRecovered:Integer;
begin
     Result:=getStatusCount(tStatus.recovered);
end;

function TPopulation.get_count: Integer;
begin
     Result:=Length(viruses);
end;

procedure TPopulation.set_virus(i: Integer; v: tVirus);
begin
     viruses[i]:=v;
end;

function TPopulation.get_virus(i: Integer): tVirus;
begin
     Result:=viruses[i];
end;

procedure TPopulation.Draw(cv: TCanvas; width, height: Integer);
var i:Integer;
begin
     for i:=0 to High(viruses) do
     begin
       viruses[i].Draw(cv, width, height);
     end;
end;

procedure TPopulation.Infection(v:tVirus);
var i:Integer;
    d:Real;
    p:tVirus;
begin
     for i:=0 to High(viruses) do
     begin
          p:=viruses[i];
          if (v<>p) and (p.Status=tStatus.healthy) then
          begin
            d:= sqrt( sqr(v.x_value - p.x_value) + sqr(v.y_value - p.y_value));
            if d<0.01 then p.Status:=tStatus.sick;
          end;
     end;
end;

procedure TPopulation.OnStep(dt: Real);
var i:Integer;
begin
     for i:=0 to High(viruses) do
     begin
         viruses[i].OneStep(dt);
         if viruses[i].Status = tStatus.sick then Infection(viruses[i]);
     end;
end;

constructor TPopulation.Create(n: Integer; n_infected:Integer=1;
  R:Integer=4; time_sick:Integer=200; time_recovered:integer=300);
const vel = 0.1;
var i:Integer;
    s:tStatus;
begin
     Randomize;
     SetLength(viruses, n);

     for i:=0 to High(viruses) do
     begin

       if i<n_infected then s:=tStatus.sick else s:=tStatus.healthy;

       viruses[i]:=tVirus.Create(
                                 Random,
                                 Random,
                                 vel - 2*vel*Random,
                                 vel - 2*vel*Random,
                                 s, R, time_sick, time_recovered
                                 );
     end;
end;

destructor TPopulation.Destroy;
var i:Integer;
begin
  if viruses<>nil then
  begin
       for i:=0 to High(viruses) do viruses[i].Free;
       Finalize(viruses);
  end;

  inherited Destroy;
end;

end.

