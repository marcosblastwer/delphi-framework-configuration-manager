unit Base.Lib;

interface

uses
  Base.Objects;

type
  ILibrary = interface(IFrameworkInterface)
    ['{8539981F-180E-479A-843F-CF59060463AA}']
    function GetLoaded: Boolean;
    function Load: Boolean;
    procedure Unload;
    property Loaded: Boolean read GetLoaded;
  end;

  TLibrary = class(TFrameworkObject, ILibrary)
  private
    FHModule: HMODULE;
    function GetLoaded: Boolean;
  protected
    function GetHash: String; virtual; abstract;
    procedure AfterLoad; virtual;
    procedure AfterUnload; virtual;
    procedure BeforeUnload; virtual;
  published
    function Load: Boolean;
    procedure Unload;
    property Loaded: Boolean read GetLoaded;
  end;

implementation

uses
  Tools.Path,
  System.Sysutils,
  Winapi.Windows;

{ TLibrary }

procedure TLibrary.AfterLoad;
var
  After: procedure of object;
begin
  InitializePackage(FHModule);
  After := nil;
  @After := GetProcAddress(FHModule, 'AfterLoad');
  if @After <> nil then
    After();
end;

procedure TLibrary.AfterUnload;
begin

end;

procedure TLibrary.BeforeUnload;
var
  Before: procedure;
begin
  @Before := GetProcAddress(FHModule, 'BeforeUnload');
  if @Before <> nil then
    Before();
end;

function TLibrary.GetLoaded: Boolean;
begin
  Result := FHModule <> 0;
end;

function TLibrary.Load: Boolean;
begin
  Result := False;
  FHModule := LoadPackage(Paths.GetLibrariesPath + GetHash + '.bpl');
  if Loaded then
  begin
    AfterLoad;
    Result := True;
  end;
end;

procedure TLibrary.Unload;
begin
  if Loaded then
  begin
    BeforeUnload;
    UnloadPackage(FHModule);
  end;
end;

end.
