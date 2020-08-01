unit Base.Argument;

interface

type
  TCondition = (
    cnBetween,
    cnEndsWith,
    cnEqual,
    cnLike,
    cnStartsWith,
    cnUnequal );

  TDataType = (
    dtBoolean,
    dtChar,
    dtDateTime,
    dtDouble,
    dtInteger,
    dtString );

  TArgumentValue = record
    DataType: TDataType;
    Content: Variant;
  end;
  TArgumentValues = array of TArgumentValue;

  TArgument = record
  private
    FCondition: TCondition;
    FProp: String;
    FValues: TArgumentValues;
  public
    function Prop(const PropertyName: String): TArgument;
    function Between(const First, Second: Integer): TArgument; overload;
    function Between(const First, Second: TDateTime): TArgument; overload;
    function EndsWith(const Value: String): TArgument;
    function Equal(const Value: Integer): TArgument; overload;
    function Equal(const Value: TDateTime): TArgument; overload;
    function Equal(const Value: String): TArgument; overload;
    function Equal(const Value: Boolean): TArgument; overload;
    function Like(const Value: String): TArgument;
    function StartsWith(const Value: String): TArgument;
    function Unequal(const Value: Integer): TArgument; overload;
    function Unequal(const Value: TDateTime): TArgument; overload;
    function Unequal(const Value: String): TArgument; overload;
    function Unequal(const Value: Boolean): TArgument; overload;
    property Condition: TCondition read FCondition;
    property PropertyName: String read FProp;
    property Values: TArgumentValues read FValues;
  end;

function Argument: TArgument;

implementation

function Argument: TArgument;
var
  A: TArgument;
begin
  Result := A;
end;

{ TArgument }

function TArgument.Between(const First, Second: Integer): TArgument;
var
  FirstArgument, SecondArgument: TArgumentValue;
begin
  FCondition := cnBetween;

  FirstArgument.DataType := dtInteger;
  FirstArgument.Content := First;

  SecondArgument.DataType := dtInteger;
  SecondArgument.Content := Second;

  SetLength(FValues, 2);
  FValues[0] := FirstArgument;
  FValues[1] := SecondArgument;

  Result := Self;
end;

function TArgument.Between(const First, Second: TDateTime): TArgument;
var
  FirstArgument, SecondArgument: TArgumentValue;
begin
  FCondition := cnBetween;

  FirstArgument.DataType := dtDateTime;
  FirstArgument.Content := First;

  SecondArgument.DataType := dtDateTime;
  SecondArgument.Content := Second;

  SetLength(FValues, 2);
  FValues[0] := FirstArgument;
  FValues[1] := SecondArgument;

  Result := Self;
end;

function TArgument.EndsWith(const Value: String): TArgument;
var
  V: TArgumentValue;
begin
  FCondition := cnEndsWith;

  V.DataType := dtString;
  V.Content := Value;

  SetLength(FValues, 1);
  FValues[0] := V;

  Result := Self;
end;

function TArgument.Equal(const Value: String): TArgument;
var
  V: TArgumentValue;
begin
  FCondition := cnEqual;

  V.DataType := dtString;
  V.Content := Value;

  SetLength(FValues, 1);
  FValues[0] := V;

  Result := Self;
end;

function TArgument.Equal(const Value: TDateTime): TArgument;
var
  V: TArgumentValue;
begin
  FCondition := cnEqual;

  V.DataType := dtDateTime;
  V.Content := Value;

  SetLength(FValues, 1);
  FValues[0] := V;

  Result := Self;
end;

function TArgument.Equal(const Value: Integer): TArgument;
var
  V: TArgumentValue;
begin
  FCondition := cnEqual;

  V.DataType := dtInteger;
  V.Content := Value;

  SetLength(FValues, 1);
  FValues[0] := V;

  Result := Self;
end;

function TArgument.Like(const Value: String): TArgument;
var
  V: TArgumentValue;
begin
  FCondition := cnLike;

  V.DataType := dtString;
  V.Content := Value;

  SetLength(FValues, 1);
  FValues[0] := V;

  Result := Self;
end;

function TArgument.Prop(const PropertyName: String): TArgument;
begin
  FProp := PropertyName;
  Result := Self;
end;

function TArgument.StartsWith(const Value: String): TArgument;
var
  V: TArgumentValue;
begin
  FCondition := cnStartsWith;

  V.DataType := dtString;
  V.Content := Value;

  SetLength(FValues, 1);
  FValues[0] := V;

  Result := Self;
end;

function TArgument.Unequal(const Value: Integer): TArgument;
var
  V: TArgumentValue;
begin
  FCondition := cnUnequal;

  V.DataType := dtInteger;
  V.Content := Value;

  SetLength(FValues, 1);
  FValues[0] := V;

  Result := Self;
end;

function TArgument.Unequal(const Value: TDateTime): TArgument;
var
  V: TArgumentValue;
begin
  FCondition := cnUnequal;

  V.DataType := dtDateTime;
  V.Content := Value;

  SetLength(FValues, 1);
  FValues[0] := V;

  Result := Self;
end;

function TArgument.Unequal(const Value: String): TArgument;
var
  V: TArgumentValue;
begin
  FCondition := cnUnequal;

  V.DataType := dtString;
  V.Content := Value;

  SetLength(FValues, 1);
  FValues[0] := V;

  Result := Self;
end;

function TArgument.Equal(const Value: Boolean): TArgument;
var
  V: TArgumentValue;
begin
  FCondition := cnEqual;

  V.DataType := dtBoolean;
  V.Content := Value;

  SetLength(FValues, 1);
  FValues[0] := V;

  Result := Self;
end;

function TArgument.Unequal(const Value: Boolean): TArgument;
var
  V: TArgumentValue;
begin
  FCondition := cnUnequal;

  V.DataType := dtBoolean;
  V.Content := Value;

  SetLength(FValues, 1);
  FValues[0] := V;

  Result := Self;
end;

end.
