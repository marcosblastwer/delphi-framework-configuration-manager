unit Tools.Path;

interface

type
  Paths = class
  public
    class function GetBinaryPath: String; static;
    class function GetLibrariesPath: String; static;
    class function GetName: String;
    class function GetPath: String; static;
    class function GetResourcesPath: String; static;
    class function GetRootPath: String; static;
    class function GetTemporaryPath: String; static;
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils;

const
  _DIRNAME_BINARY = 'bin';
  _DIRNAME_LIBRARIES = 'lib';
  _DIRNAME_RESOURCES = 'resources';

{ App }

class function Paths.GetBinaryPath: String;
begin
  Result := IncludeTrailingPathDelimiter(Paths.GetRootPath + _DIRNAME_BINARY);
end;

class function Paths.GetLibrariesPath: String;
begin
  Result := IncludeTrailingPathDelimiter(Paths.GetRootPath + _DIRNAME_LIBRARIES);
end;

class function Paths.GetName: String;
begin
  Result := 'Majoris';
end;

class function Paths.GetPath: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
end;

class function Paths.GetResourcesPath: String;
begin
  Result := IncludeTrailingPathDelimiter(Paths.GetRootPath + _DIRNAME_RESOURCES);
end;

class function Paths.GetRootPath: String;
var
  DirName: String;
begin
  Result := ExcludeTrailingPathDelimiter(Paths.GetPath);
  DirName := ExtractFileName(Result);
  if (DirName = _DIRNAME_BINARY) or (DirName = _DIRNAME_LIBRARIES) or (DirName = _DIRNAME_RESOURCES) then
    Result := ExtractFilePath(Result)
  else
    Result := IncludeTrailingPathDelimiter(Result);
end;

class function Paths.GetTemporaryPath: String;
begin
  Result := IncludeTrailingPathDelimiter(TPath.GetTempPath + Paths.GetName);
  if not DirectoryExists(Result) then
    CreateDir(Result);
end;

end.
