unit Configuration;

interface

uses
  Base.Objects;

type
  IConfiguration = interface(IFrameworkInterface)
    ['{E1F8D997-2335-49E5-8958-B66B3408DD7B}']
  end;

  TConfiguration = class(TFrameworkObject, IConfiguration)
  end;

  Configurations = class
  private
    class function GetDir: String;
    class function GetName<TInterface: IConfiguration>: String;
    class function GetPath<TInterface: IConfiguration>: String;
    class procedure ConfirmDir;
  public
    class function Configured<TInterface: IConfiguration>: Boolean;
    class procedure Delete<TInterface: IConfiguration>;
    class procedure Load<TInterface: IConfiguration>(var Config: TInterface);
    class procedure RegisterConfiguration<TInterface: IConfiguration; TImplementation: class>;
    class procedure Save<TInterface: IConfiguration>(const Config: TInterface);
  end;

implementation

uses
  System.Classes,
  System.SysUtils,
  Tools.Encryption,
  Tools.Path;

{ Configurations }

class function Configurations.Configured<TInterface>: Boolean;
begin
  Result := FileExists(GetPath<TInterface>);
end;

class procedure Configurations.ConfirmDir;
var
  D: String;
begin
  D := GetDir;

  if DirectoryExists(D) then
    Exit;

  CreateDir(D);

  Sleep(100);
end;

class procedure Configurations.Delete<TInterface>;
var
  Path: String;
begin
  Path := GetPath<TInterface>;

  if FileExists(Path) then
    DeleteFile(Path);
end;

class function Configurations.GetDir: String;
begin
  Result := IncludeTrailingPathDelimiter(Paths.GetPath + 'config');
end;

class function Configurations.GetName<TInterface>: String;
begin
  Result := Objects.GetGuid<TInterface>().ToString + '.config';
end;

class function Configurations.GetPath<TInterface>: String;
begin
  Result := GetDir + GetName<TInterface>;
end;

class procedure Configurations.Load<TInterface>(var Config: TInterface);
var
  Content: String;
  F: TStrings;
begin
  Config := Objects.New<TInterface>('_config');

  if not FileExists(GetPath<TInterface>) then
    Exit;

  Content := EmptyStr;

  F := TStringList.Create;
  try
    F.LoadFromFile(GetPath<TInterface>);
    if F.Text.Trim = '' then
      Exit;
    Content := Trim(F.Text);
  finally
    F.Free;
    F := nil;
  end;

  if Content = '' then
    Exit;
  Content := Encryption.Decrypt(Content);

  Config := Objects.New<TInterface>('_config', Content);
end;

class procedure Configurations.RegisterConfiguration<TInterface, TImplementation>;
begin
  Objects.RegisterType<TInterface, TImplementation>('_config');
end;

class procedure Configurations.Save<TInterface>(const Config: TInterface);
var
  Content: String;
  F: TStrings;
begin
  Content := Trim(Config.Serialize);

  if Content = '' then
    Exit;

  Content := Encryption.Encrypt(Trim(Content));

  ConfirmDir;

  F := TStringList.Create;
  try
    F.Add(Content);
    F.SaveToFile(GetPath<TInterface>);
  finally
    F.Free;
    F := nil;
  end;
end;

end.
