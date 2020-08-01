unit Tools.Json;

interface

type
  Json = class
    class function Map(const Instance: TObject): String; overload;
    class function Map(const JsonString: String): TObject; overload;
  end;

implementation

uses
  System.JSON,
  System.SysUtils,
  Data.DBXJSONReflect;

{ Json }

class function Json.Map(const Instance: TObject): String;
var
  lMarshal: TJSONMarshal;
begin
  lMarshal := TJSONMarshal.Create(TJSONConverter.Create);
  try
    Result := lMarshal.Marshal(Instance).ToString();
  finally
    FreeAndNil(lMarshal);
  end;
end;

class function Json.Map(const JsonString: String): TObject;
var
  lUnmarshal: TJSONUnMarshal;
  obj: TObject;
begin
  lUnmarshal := TJSONUnMarshal.Create;
  try
    obj := lUnmarshal.Unmarshal(TJSONObject.ParseJSONValue(JsonString));
    Result := obj as TObject;
  finally
    FreeAndNil(lUnmarshal);
  end;
end;

end.
