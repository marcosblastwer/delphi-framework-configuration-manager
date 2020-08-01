unit Base.Converter;

interface

type
  Convert = class
    class function ToChar(const Value: String): Char; overload;
    class function ToChar(const Value: Integer): Char; overload;
    class function ToFloat(const Value: String): Extended; overload;
    class function ToFloat(const Value: String; const Default: Extended): Extended; overload;
    class function ToInteger(const Value: String): Integer; overload;
    class function ToInteger(const Value: String; const Default: Integer): Integer; overload;
    class function ToInteger(const Value: Double): Integer; overload;
    class function ToInt64(const Value: String): Int64; overload;
    class function ToInt64(const Value: String; const Default: Int64): Int64; overload;
    class function ToInt64(const Value: Double): Int64; overload;
    class function ToMilliseconds(const Value: TTime): Int64;
    class function ToString(const Value: Integer): String; reintroduce;
  end;

implementation

uses
  System.SysUtils;

{ Convert }

class function Convert.ToInteger(const Value: String): Integer;
begin
  Result := StrToInt(Value);
end;

class function Convert.ToInt64(const Value: String): Int64;
begin
  Result := StrToInt64(Value);
end;

class function Convert.ToInt64(const Value: String;
  const Default: Int64): Int64;
begin
  Result := StrToInt64Def(Value, Default);
end;

class function Convert.ToFloat(const Value: String): Extended;
begin
  Result := StrToFloat(Value);
end;

class function Convert.ToChar(const Value: String): Char;
begin
  Result := #0;
  if Length(Value) > 0 then
    Result := Value[1];
end;

class function Convert.ToChar(const Value: Integer): Char;
begin
  Result := ToChar(Value.ToString);
end;

class function Convert.ToFloat(const Value: String;
  const Default: Extended): Extended;
begin
  Result := StrToFloatDef(Value, Default)
end;

class function Convert.ToInt64(const Value: Double): Int64;
begin
  Result := Trunc(Value);
end;

class function Convert.ToInteger(const Value: Double): Integer;
begin
  Result := Trunc(Value);
end;

class function Convert.ToMilliseconds(const Value: TTime): Int64;
begin
  Result := ToInteger(FormatDateTime('zzz', Value), 0) +
    (ToInteger(FormatDateTime('hh', Value), 0) * 3600000) +
    (ToInteger(FormatDateTime('nn', Value), 0) * 60000) +
    (ToInteger(FormatDateTime('ss', Value), 0) * 1000);
end;

class function Convert.ToString(const Value: Integer): String;
begin
  Result := IntToStr(Value);
end;

class function Convert.ToInteger(const Value: String;
  const Default: Integer): Integer;
begin
  Result := StrToIntDef(Value, Default);
end;

end.
