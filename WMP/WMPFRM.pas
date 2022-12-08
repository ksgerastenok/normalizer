unit
  WMPFRM;

interface

uses
  WMPDCL,
  Forms,
  Controls,
  ComCtrls,
  StdCtrls,
  SysUtils;

type
  PWMPFRM = ^TWMPFRM;
  TWMPFRM = record
  private
    var finfo: TInfo;
    var fform: TForm;
    function CreateForm(const Top, Left, Width, Height: Integer; const Caption: String): TForm;
    function CreateTrackBar(const Top, Left, Width, Height: Integer; const Tag: Integer): TTrackBar;
    procedure Create();
    procedure Destroy();
  public
    procedure Init();
    procedure Done();
    procedure Show();
    procedure Hide();
    procedure Update(const Value: Integer);
  end;

implementation

uses
  Math,
  StrUtils,
  Interfaces;

procedure TWMPFRM.Init();
begin
  self.Create();
end;

procedure TWMPFRM.Done();
begin
  self.Destroy();
end;

procedure TWMPFRM.Show();
begin
  self.fform.Show();
end;

procedure TWMPFRM.Hide();
begin
  self.fform.Hide();
end;

procedure TWMPFRM.Create();
var
  i: Integer;
begin
  Application.Initialize();
  self.fform := self.CreateForm(120, 215, 450, 25, 'Normalizer');
  self.fform.InsertControl(self.CreateTrackBar(0, 0, 450, 20, 0));
end;

procedure TWMPFRM.Destroy();
var
  i: Integer;
begin
  self.fform.Hide();
  for i := 0 to self.fform.ControlCount - 1 do begin
    self.fform.Controls[i].Destroy();
  end;
  self.fform.Destroy();
  Application.Terminate();
end;

function TWMPFRM.CreateForm(const Top, Left, Width, Height: Integer; const Caption: String): TForm;
begin
  Result := TForm.Create(Application);
  Result.Font.Size := 8;
  Result.Caption := Caption;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
  Result.BorderIcons := [biSystemMenu];
  Result.BorderStyle := bsSingle;
  Result.Position := poMainFormCenter;
  Result.ShowHint := True;
end;

function TWMPFRM.CreateTrackBar(const Top, Left, Width, Height: Integer; const Tag: Integer): TTrackBar;
begin
  Result := TTrackBar.Create(Application);
  Result.Font.Size := 8;
  Result.Orientation := trHorizontal;
  Result.Tag := Tag;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
  Result.Min := 0;
  Result.Position := 0;
  Result.Max := 20;
  Result.ShowHint := True;
  Result.TickMarks := tmBoth;
  Result.TickStyle := tsNone;
end;

procedure TWMPFRM.Update(const Value: Integer);
var
  i: Integer;
begin
  for i := 0 to self.fform.ControlCount - 1 do begin
    if (self.fform.Controls[i] is TTrackBar) then begin
      with (self.fform.Controls[i] as TTrackBar) do begin
        Position := Value;
      end;
    end;
  end;
end;

begin
end.
