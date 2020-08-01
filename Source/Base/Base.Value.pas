unit Base.Value;

interface

uses
  Base.Objects;

type
  TValueKind = (
    vkNone,
    vkBoolean,
    vkChar,
    vkDate,
    vkDateTime,
    vkField,
    vkFloat,
    vkInt,
    vkStr,
    vkTable,
    vkTime );

  IValue = interface(IFrameworkInterface)
    ['{87450560-D883-4837-BCE9-72F8A3F5BDB7}']
    function GetKind: TValueKind;
    function GetValue: Variant;
    function SetKind(const AKind: TValueKind): IValue;
    function SetValue(const AValue: Variant): IValue;
    property Kind: TValueKind read GetKind;
    property Value: Variant read GetValue;
  end;

  ValueRepository = class
  private
    class function Instantiate(const Kind: TValueKind): IValue;
  public
    class function &Boolean(const Value: Boolean): IValue;
    class function &Char(const Value: Char): IValue;
    class function &Date(const Value: TDate): IValue;
    class function &DateTime(const Value: TDateTime): IValue;
    class function &Field(const Value: String): IValue;
    class function &Float(const Value: Extended): IValue;
    class function &Int(const Value: Integer): IValue;
    class function &String(const Value: String): IValue;
    class function &Table(const Value: String): IValue;
    class function &Time(const Value: TTime): IValue;
  end;

implementation

type
  TValue = class(TFrameworkObject, IValue)
  private
    FKind: TValueKind;
    FValue: Variant;
    function GetKind: TValueKind;
    function GetValue: Variant;
    function SetKind(const AKind: TValueKind): IValue;
    function SetValue(const AValue: Variant): IValue;
  public
    constructor Create;
  end;

{ TValue }

constructor TValue.Create;
begin
  inherited;
  FKind := vkNone;
end;

function TValue.GetKind: TValueKind;
begin
  Result := FKind;
end;

function TValue.GetValue: Variant;
begin
  Result := FValue;
end;

function TValue.SetKind(const AKind: TValueKind): IValue;
begin
  FKind := AKind;
  Result := Self;
end;

function TValue.SetValue(const AValue: Variant): IValue;
begin
  FValue := AValue;
  Result := Self;
end;

{ ValueRepository }

class function ValueRepository.Boolean(const Value: Boolean): IValue;
begin
  Result := Instantiate(vkBoolean);
  Result.SetValue(Value);
end;

class function ValueRepository.Char(const Value: Char): IValue;
begin
  Result := Instantiate(vkChar);
  Result.SetValue(Value);
end;

class function ValueRepository.Date(const Value: TDate): IValue;
begin
  Result := Instantiate(vkDate);
  Result.SetValue(Value);
end;

class function ValueRepository.DateTime(const Value: TDateTime): IValue;
begin
  Result := Instantiate(vkDateTime);
  Result.SetValue(Value);
end;

class function ValueRepository.Field(const Value: String): IValue;
begin
  Result := Instantiate(vkField);
  Result.SetValue(Value);
end;

class function ValueRepository.Float(const Value: Extended): IValue;
begin
  Result := Instantiate(vkField);
  Result.SetValue(Value);
end;

class function ValueRepository.Instantiate(const Kind: TValueKind): IValue;
begin
  Result := Objects.New<IValue>;
  Result.SetKind(Kind);
end;

class function ValueRepository.Int(const Value: Integer): IValue;
begin
  Result := Instantiate(vkInt);
  Result.SetValue(Value);
end;

class function ValueRepository.&String(const Value: String): IValue;
begin
  Result := Instantiate(vkStr);
  Result.SetValue(Value);
end;

class function ValueRepository.Table(const Value: String): IValue;
begin
  Result := Instantiate(vkTable);
  Result.SetValue(Value);
end;

class function ValueRepository.Time(const Value: TTime): IValue;
begin
  Result := Instantiate(vkTime);
  Result.SetValue(Value);
end;

initialization
  Objects.RegisterType<IValue, TValue>;

end.
