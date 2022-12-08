unit
  WMPNRM;

interface

uses
  WMPDCL,
  WMPDSP,
  WMPFRM;

type
  PWMPNRM = ^TWMPNRM;
  TWMPNRM = record
  private
    class var fenabled: Boolean;
    class var famp: array[0..4] of Double;
    class var fdsp: TWMPDSP;
    class var ffrm: TWMPFRM;
    class function Init(const Module: PPlugin): Integer; cdecl; static;
    class procedure Quit(const Module: PPlugin); cdecl; static;
    class function Modify(const Module: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl; static;
    class procedure Config(const Module: PPlugin); cdecl; static;
  public
    class function Plugin(): PPlugin; cdecl; static;
  end;

implementation

uses
  Math;

class function TWMPNRM.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Nullsoft Normalizer v3.51';
  Result.Instance := $0000;
  Result.Init := TWMPNRM.Init;
  Result.Quit := TWMPNRM.Quit;
  Result.Modify := TWMPNRM.Modify;
  Result.Config := TWMPNRM.Config;
end;

class function TWMPNRM.Init(const Module: PPlugin): Integer; cdecl;
var
  k: Integer;
begin
  TWMPNRM.ffrm.Init();
  TWMPNRM.fdsp.Init();
  TWMPNRM.fenabled := True;
  for k := 0 to Length(TWMPNRM.famp) - 1 do begin
    TWMPNRM.famp[k] := 1.0;
  end;
  Result := 0;
end;

class procedure TWMPNRM.Quit(const Module: PPlugin); cdecl;
var
  k: Integer;
begin
  for k := 0 to Length(TWMPNRM.famp) - 1 do begin
    TWMPNRM.famp[k] := 1.0;
  end;
  TWMPNRM.fenabled := False;
  TWMPNRM.fdsp.Done();
  TWMPNRM.ffrm.Done();
end;

class function TWMPNRM.Modify(const Module: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
  f: Double;
  a: Double;
  b: Double;
  y: Double;
begin
  TWMPNRM.fdsp.Data.Data := Data;
  TWMPNRM.fdsp.Data.Bits := Bits;
  TWMPNRM.fdsp.Data.Rates := Rates;
  TWMPNRM.fdsp.Data.Samples := Samples;
  TWMPNRM.fdsp.Data.Channels := Channels;
  if (TWMPNRM.fenabled) then begin
    for k := 0 to TWMPNRM.fdsp.Data.Channels - 1 do begin
      f := 0;
      for x := 0 to TWMPNRM.fdsp.Data.Samples - 1 do begin
        f := f + (Sqr(TWMPNRM.fdsp.Samples[x, k]) - f) / (x + 1);
      end;
      b := Min(Max(1.0, 1.0 / Sqrt(5.0 * f)), 10.0);
      a := TWMPNRM.famp[k];
      for x := 0 to TWMPNRM.fdsp.Data.Samples - 1 do begin
        if (b <= a) then begin
          //y := (2 * (a - b) / Pi) * ArcTan2(Tan((0.01 * b * Pi) / (2 * (a - b))) * 0.2 * self.fdsp.Data.Rates, x) + b;
          //y := b * (x * (a - b * (1.0 + 0.01)) + 0.01 * a * 0.35 * self.fdsp.Data.Rates) / (x * (a - b * (1.0 + 0.01)) + 0.01 * b * 0.35 * self.fdsp.Data.Rates);
          y := (b - a) * Min(Max(0.0, x / (0.2 * TWMPNRM.fdsp.Data.Rates)), 1.0) + a;
        end         else begin
          //y := (2 * (b - a) / Pi) * ArcTan2(x, Tan((0.01 * b * Pi) / (2 * (b - a))) * 5.0 * self.fdsp.Data.Rates) + a;
          //y := b * (x * (a - b * (1.0 - 0.01)) - 0.01 * a * 35.0 * self.fdsp.Data.Rates) / (x * (a - b * (1.0 - 0.01)) - 0.01 * b * 35.0 * self.fdsp.Data.Rates);
          y := (b - a) * Min(Max(0.0, x / (5.0 * TWMPNRM.fdsp.Data.Rates)), 1.0) + a;
        end;
        TWMPNRM.fdsp.Samples[x, k] := y * TWMPNRM.fdsp.Samples[x, k];
      end;
      TWMPNRM.famp[k] := y;
    end;
  end;
  f := 0;
  for k := 0 to Length(TWMPNRM.famp) - 1 do begin
    if (k < TWMPNRM.fdsp.Data.Channels) then begin
      f := f + (TWMPNRM.famp[k] - f) / (k + 1);
    end;
  end;
  TWMPNRM.ffrm.Update(Round(20 * Log10(f)));
  Result := Samples;
end;

class procedure TWMPNRM.Config(const Module: PPlugin); cdecl;
begin
  TWMPNRM.ffrm.Show();
end;

begin
end.
