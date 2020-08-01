unit Base.Objects;

interface

uses
  Base.Objects.Types,
  Base.Argument,
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  System.TypInfo;

type
{$M+}
{$TYPEINFO ON}

  IFrameworkInterface = interface(IInterface)
    ['{6A52827A-BFC2-4281-A663-121171E0F8B8}']
    function Serialize: String;
    function Support(const IID: TGUID): Boolean;
  end;

  TFrameworkObject = class(TInterfacedObject, IFrameworkInterface)
  published
    constructor Create;
    function Serialize: String;
    function Support(const IID: TGUID): Boolean;
  end;

  IList = interface(IInterfaceList)
    ['{F950C78F-6A38-41A3-B96E-16523B1ED7EE}']
    function Empty: Boolean;
    function GetIterator: IIterator;
    property Iterator: IIterator read GetIterator;
  end;

  IList<TInterface: IFrameworkInterface> = interface(IFrameworkInterface)
    ['{4DBECBAF-15E0-42E3-B8B7-21AB12934FD7}']
    procedure Add(Items: IList<TInterface>); overload;
    procedure Add(Items: array of TInterface); overload;
    function Add(Item: TInterface): Integer; overload;
    function Count: Integer;
    function Empty: Boolean;
    function Find(const Args: array of TArgument): TInterface;
    function First: TInterface;
    function Get(const Index: Integer): TInterface;
    function GetItems: TArray<TInterface>;
    function Last: TInterface;
    function Remove(const Item: TInterface): Boolean; overload;
    function Remove(const Index: Integer): Boolean; overload;
    procedure Clear;
    property Items: TArray<TInterface> read GetItems;
  end;

  TQueryable<TInterface: IFrameworkInterface> = class(TFrameworkObject, IList<TInterface>)
  private
    type
      TContainerObject<TIInterface: IFrameworkInterface> = class
      public
        IInterface: PTypeInfo;
        Instance: TInterface;
      end;
  private
    FContainer: TDictionary<Integer, System.TObject>;
    function Match(const Item1, Item2: TInterface): Boolean; overload;
    function Match(const Item: TInterface; const Args: array of TArgument): Boolean; overload;
    function Match(const Item: TInterface; const Arg: TArgument): Boolean; overload;
    function InsideBounds(const Index: Integer): Boolean;
    function GetItems: TArray<TInterface>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Items: IList<TInterface>); overload;
    procedure Add(Items: array of TInterface); overload;
    function Add(Item: TInterface): Integer; overload;
    function Count: Integer;
    function Empty: Boolean;
    function Find(const Args: array of TArgument): TInterface;
    function First: TInterface;
    function Get(const Index: Integer): TInterface;
    function Last: TInterface;
    function Remove(const Item: TInterface): Boolean; overload;
    function Remove(const Index: Integer): Boolean; overload;
    procedure Clear;
    property Items: TArray<TInterface> read GetItems;
  end;

  Objects = class
  private
    class var
      Container: TDictionary<String, System.TObject>;
    type
      TContainerObject<TInterface: IFrameworkInterface> = class
      public
        IInterface: PTypeInfo;
        TImplementation: TClass;
      end;
    class procedure Initialize;
    class procedure Finalize;
    class function CreateInstance(const AClass: TClass): IInterface;
  public
    class procedure RegisterType<TInterface: IFrameworkInterface; TImplementation: class>(const Name: String = '');
    class procedure Unregister<TInterface: IFrameworkInterface>(const Name: String = '');
    class function New<TInterface: IFrameworkInterface>(const Name: String = ''): TInterface; overload;
    class function New<TInterface: IFrameworkInterface>(const Name: String; const Content: String): TInterface; overload;
    class function NewList: IList; overload;
    class function NewList<TInterface: IFrameworkInterface>: IList<TInterface>; overload;
    class function GetGuid<TInterface: IFrameworkInterface>: TGUID;
    class function GetTypeName<TInterface: IFrameworkInterface>: String;
  end;

  EObjectException = class(Exception);

  EUnregisteredInterfaceException = class(EObjectException)
    constructor Create(const InterfaceName: String);
  end;

  EAlreadyRegisteredException = class(EObjectException)
    constructor Create(const InterfaceName: String);
  end;

  EClassNotImplementException = class(EObjectException);
  EImplementationNotRegisteredException = class(EObjectException);

implementation

uses
  Tools.Json;

type
  TList = class(TInterfaceList, IList)
  private
    FIterator: IIterator;
    function GetList: IList;
  public
    function Empty: Boolean;
    function GetIterator: IIterator;
    property Iterator: IIterator read GetIterator;
  end;

  TIteratorList = function : IList of object;

  TIterator = class(TInterfacedObject, IIterator)
  protected
    FIndex : Integer;
    FIteratorList: TIteratorList;
  public
    constructor Create(AIteratorList: TIteratorList);
    procedure Reset;
    function CurrentItem: IInterface;
    function Eof: Boolean;
    function First: IInterface;
    function Get(const Index: Integer): IInterface;
    function GetIndex: Integer;
    function Last: IInterface;
    function Next: Boolean;
  end;

{ TFrameworkObject }

constructor TFrameworkObject.Create;
begin
  inherited Create;
end;

function TFrameworkObject.Serialize: String;
begin
  Result := Json.Map(Self);
end;

function TFrameworkObject.Support(const IID: TGUID): Boolean;
begin
  Result := Supports(Self, IID);
end;

{ Objects }

class function Objects.CreateInstance(const AClass: TClass): IInterface;
var
  RttiCtx: TRttiContext;
  RType : TRttiType;
  Method: TRttiMethod;
begin
  Result := nil;
  RttiCtx := TRttiContext.Create;
  try
    RType := RttiCtx.GetType(AClass);
  finally
    RttiCtx.Free;
  end;
  if not (RType is TRttiInstanceType) then
    Exit;
  for Method in TRttiInstanceType(RType).GetMethods do
    if Method.IsConstructor and (Length(Method.GetParameters) = 0) then
    begin
      Result := Method.Invoke(TRttiInstanceType(RType).MetaclassType, []).AsInterface;
      Break;
    end;
end;

class procedure Objects.Finalize;
var
  O: System.TObject;
begin
  for O in Container.Values do
  begin
    if O <> nil then
      try
        O.Free;
      except end;
  end;
  try
    Container.Clear;
  except end;
  try
    FreeAndNil(Container);
  except end;
end;

class function Objects.GetGuid<TInterface>: TGUID;
begin
  Result := GetTypeData(TypeInfo(TInterface))^.Guid;
end;

class function Objects.GetTypeName<TInterface>: String;
var
  PInfo: PTypeInfo;
begin
  PInfo := TypeInfo(TInterface);
  Result := String(PInfo.Name);
end;

class procedure Objects.Initialize;
begin
  Container := TDictionary<String, System.TObject>.Create;
end;

class function Objects.New<TInterface>(const Name: String): TInterface;
var
  CObject: TContainerObject<TInterface>;
  Key: String;
  Imp: TInterface;
  Intf: IInterface;
  O: System.TObject;
  PInfo: PTypeInfo;
begin
  Result := Default(TInterface);
  PInfo := TypeInfo(TInterface);
  Key := String(PInfo.Name) + Trim(Name);

  if not Container.TryGetValue(Key, O) then
  begin
    raise EUnregisteredInterfaceException.Create(String(PInfo.Name));
    Exit;
  end;
  CObject := TContainerObject<TInterface>(O);

  MonitorEnter(Container);
  try
    if CObject.TImplementation <> nil then
      try
        Intf := CreateInstance(CObject.TImplementation);
      except
        on E:Exception do
        begin
          Unregister<TInterface>;
          raise EUnregisteredInterfaceException.Create(String(PInfo.Name) + #13 + E.Message);
        end;
      end;
    if Intf = nil then
    begin
      raise EClassNotImplementException.Create(
        Format('The Implementation registered for type %s does not actually implement %s', [PInfo.Name, PInfo.Name]) );
      Exit;
    end;
    if Intf.QueryInterface(GetTypeData(TypeInfo(TInterface)).Guid, Imp) <> 0 then
    begin
      raise EImplementationNotRegisteredException.Create(
        Format('The Implementation registered for type %s does not actually implement %s', [PInfo.Name, PInfo.Name]) );
      Exit;
    end;
    Result := Imp;
  finally
    MonitorExit(Container);
  end;
end;

class function Objects.New<TInterface>(const Name: String;
  const Content: String): TInterface;
var
  O: TObject;
  PData: PTypeData;
begin
  O := Json.Map(Content);
  PData := GetTypeData(TypeInfo(TInterface));
  if (ifHasGuid in PData.IntfFlags) then
    TFrameworkObject(O).QueryInterface(PData.Guid, Result)
  else
    raise Exception.Create('Can''t cast object to interface.');
end;

class function Objects.NewList: IList;
begin
  Result := TList.Create;
end;

class function Objects.NewList<TInterface>: IList<TInterface>;
begin
  Result := TQueryable<TInterface>.Create;
end;

class procedure Objects.RegisterType<TInterface, TImplementation>(const Name: String);
var
  Key: String;
  CObject: TContainerObject<TInterface>;
  O: TObject;
  PInfo: PTypeInfo;
begin
  PInfo := TypeInfo(TInterface);
  Key := String(PInfo.Name) + Trim(Name);

  if Container.TryGetValue(Key, O) then
    Exit;

  CObject := TContainerObject<TInterface>.Create;
  CObject.IInterface := PInfo;
  CObject.TImplementation := TImplementation;

  MonitorEnter(Container);
  try
    Container.Add(Key, CObject);
  finally
    MonitorExit(Container);
  end;
end;

class procedure Objects.Unregister<TInterface>(const Name: String);
var
  Key: String;
  O: TObject;
  PInfo: PTypeInfo;
begin
  PInfo := TypeInfo(TInterface);
  Key := String(PInfo.Name) + Trim(Name);
  if Container.TryGetValue(Key, O) then
    Container.Remove(Key);
end;

{ TList }

function TList.Empty: Boolean;
begin
  Result := Count <= 0;
end;

function TList.GetIterator: IIterator;
begin
  if FIterator = nil then
    FIterator := TIterator.Create(GetList);
  Result := FIterator;
end;

function TList.GetList: IList;
begin
  Result := Self;
end;

{ TIterator }

constructor TIterator.Create(AIteratorList: TIteratorList);
begin
  inherited Create;
  FIteratorList := AIteratorList;
end;

function TIterator.CurrentItem: IInterface;
begin
  if (Assigned(FIteratorList)) and ((FIndex >= 0) and (FIndex < FIteratorList.Count)) then
    Result := (FIteratorList[FIndex] as IInterface)
  else
    Result := nil;
end;

function TIterator.Eof: Boolean;
begin
  Result := not ((Assigned(FIteratorList)) and (FIndex < (FIteratorList.Count - 1)));
end;

function TIterator.First: IInterface;
begin
  FIndex := 0;
  Result := CurrentItem;
end;

function TIterator.Get(const Index: Integer): IInterface;
begin
  FIndex := Index;
  Result := CurrentItem;
end;

function TIterator.GetIndex: Integer;
begin
  Result := FIndex;
end;

function TIterator.Last: IInterface;
begin
  FIndex := FIteratorList.Count -1;
  Result := CurrentItem;
end;

function TIterator.Next: Boolean;
begin
  Result := (Assigned(FIteratorList)) and (FIndex < (FIteratorList.Count - 1));
  if Result then
    Inc(FIndex);
end;

procedure TIterator.Reset;
begin
  FIndex := -1;
end;

{ TQueryable<TInterface> }

function TQueryable<TInterface>.Add(Item: TInterface): Integer;
var
  Index: Integer;
  O: TContainerObject<TInterface>;
  PInfo: PTypeInfo;
begin
  Index := FContainer.Count;
  PInfo := TypeInfo(TInterface);
  O := TContainerObject<TInterface>.Create;
  O.IInterface := PInfo;
  O.Instance := Item;
  FContainer.Add(Index, O);
  Result := Index;
end;

function TQueryable<TInterface>.Match(const Item: TInterface;
  const Args: array of TArgument): Boolean;
var
  Arg: TArgument;
begin
  Result := True;
  for Arg in Args do
  begin
    Result := Result and Match(Item, Arg);
    if not Result then
      Break;
  end;
end;

function TQueryable<TInterface>.Match(const Item: TInterface;
  const Arg: TArgument): Boolean;
var
  PropInfo: PPropInfo;
  Value, ArgumentValue: Variant;
  Instance: TObject;
begin
  Result := False;
  PropInfo :=
    GetPropInfo( TypeInfo(TInterface), Arg.PropertyName );
  if PropInfo = nil then
    Exit;
  Instance := TObject(TFrameworkObject(Item));
  Value := GetPropValue(Instance, PropInfo);
  case Arg.Condition of
    cnBetween:
      Result := (Value >= Arg.Values[0].Content) and (Value <= Arg.Values[0].Content);
    cnEndsWith:
      Result := Copy(Value, Length(Value) - Length(Arg.Values[0].Content), Length(Arg.Values[0].Content)) = Arg.Values[0].Content;
    cnEqual:
      Result := Value = Arg.Values[0].Content;
    cnLike:
      Result := Pos(Arg.Values[0].Content, Value) > 0;
    cnStartsWith:
      Result := Copy(Value, 1, Length(Arg.Values[0].Content)) = Arg.Values[0].Content;
    cnUnequal:
      Result := Value <> Arg.Values[0].Content;
  end;
end;

procedure TQueryable<TInterface>.Add(Items: IList<TInterface>);
var
  Item: TInterface;
begin
  for Item in Items.Items do
    Add(Item);
end;

procedure TQueryable<TInterface>.Add(Items: array of TInterface);
var
  I: TInterface;
begin
  for I in Items do
    Add(I);
end;

procedure TQueryable<TInterface>.Clear;
begin
  FContainer.Clear;
end;

function TQueryable<TInterface>.Count: Integer;
begin
  Result := FContainer.Count;
end;

constructor TQueryable<TInterface>.Create;
begin
  inherited Create;
  FContainer := TDictionary<Integer, System.TObject>.Create;
end;

destructor TQueryable<TInterface>.Destroy;
var
  Index: Integer;
  O: TContainerObject<TInterface>;
begin
  if Assigned(FContainer) then
  begin
    try
      for Index := 0 to FContainer.Count -1 do
        try
          O := FContainer.Items[Index] as TContainerObject<Tinterface>;
          if Assigned(O) then
            O.Free;
          O := nil;
        except end;
    except end;
    try
      FContainer.Clear;
    except end;
    try
      FreeAndNil(FContainer);
    except end;
  end;
  inherited;
end;

function TQueryable<TInterface>.Empty: Boolean;
begin
  Result := FContainer.Count <= 0;
end;

function TQueryable<TInterface>.Find(
  const Args: array of TArgument): TInterface;
var
  Index: Integer;
  Item: TInterface;
begin
  Result := nil;
  if Length(Args) = 0 then
    Exit;
  if FContainer.Count = 0 then
    Exit;
  for Index := 0 to FContainer.Count -1 do
  begin
    Item := (FContainer.Items[Index] as TContainerObject<TInterface>).Instance;
    if Match(Item, Args) then
    begin
      Result := Item;
      Break;
    end;
  end;
end;

function TQueryable<TInterface>.First: TInterface;
var
  O: System.TObject;
begin
  Result := nil;
  if FContainer.TryGetValue(0, O) then
    Result := (O as TContainerObject<TInterface>).Instance;
end;

function TQueryable<TInterface>.Get(const Index: Integer): TInterface;
var
  O: System.TObject;
begin
  Result := nil;
  if not InsideBounds(Index) then
    Exit;
  if FContainer.TryGetValue(Index, O) then
    Result := (O as TContainerObject<TInterface>).Instance;
end;

function TQueryable<TInterface>.GetItems: TArray<TInterface>;
var
  Index: Integer;
  O: System.TObject;
begin
  SetLength(Result, 0);
  if FContainer.Count = 0 then
    Exit;
  O := nil;
  SetLength(Result, FContainer.Count);
  for Index := 0 to FContainer.Count - 1 do
    try
      FContainer.TryGetValue(Index, O);
      Result[Index] := (O as TContainerObject<TInterface>).Instance;
    finally
      O := nil;
    end;
end;

function TQueryable<TInterface>.InsideBounds(
  const Index: Integer): Boolean;
begin
  Result := (Index >= 0) and (Index < FContainer.Count);
end;

function TQueryable<TInterface>.Last: TInterface;
var
  Index: Integer;
  O: System.TObject;
begin
  Result := nil;
  Index := FContainer.Count -1;
  if not InsideBounds(Index) then
    Exit;
  if FContainer.TryGetValue(Index, O) then
    Result := (O as TContainerObject<TInterface>).Instance;
end;

function TQueryable<TInterface>.Match(const Item1,
  Item2: TInterface): Boolean;
var
  PropList1,
  PropList2: PPropList;
  PropValue1, PropValue2: Variant;
  Count, Index: Integer;
begin
  Result := True;
  Count := GetPropList( TypeInfo(TInterface), PropList1 );
  GetPropList( TypeInfo(TInterface), PropList2 );
  for Index := 0 to Count -1 do
  begin
    PropValue1 := GetPropValue(TObject(TFrameworkObject(Item1)), String(PropList1^[Index].Name));
    PropValue2 := GetPropValue(TObject(TFrameworkObject(Item2)), String(PropList2^[Index].Name));
    Result := Result
      and (PropList1^[Index].Name = PropList2^[Index].Name)
      and (PropList1^[Index].PropType^.Kind = PropList2^[Index].PropType^.Kind)
      and (PropList1^[Index].PropType^.Name = PropList1^[Index].PropType^.Name)
      and (PropValue1 = PropValue2);
  end;
end;

function TQueryable<TInterface>.Remove(const Item: TInterface): Boolean;
var
  Index: Integer;
  O: System.TObject;
  I: TInterface;
begin
  Result := False;
  for Index := 0 to FContainer.Count -1 do
    if FContainer.TryGetValue(Index, O) and Match(Item, (O as TContainerObject<TInterface>).Instance) then
    begin
      FContainer.Remove(Index);
      Result := True;
      Break;
    end;
  O := nil;
end;

function TQueryable<TInterface>.Remove(const Index: Integer): Boolean;
begin
  Result := True;
  if InsideBounds(Index) then
    FContainer.Remove(Index);
end;

{ EUnregisteredInterfaceException }

constructor EUnregisteredInterfaceException.Create(
  const InterfaceName: String);
begin
  inherited Create(
    'No implementation registered for type "' + InterfaceName + '".');
end;

{ EAlreadyRegisteredException }

constructor EAlreadyRegisteredException.Create(
  const InterfaceName: String);
begin
  inherited Create('Type "' + InterfaceName + '" has already been registered.');
end;

initialization
  Objects.Initialize;

finalization
  Objects.Finalize;

end.
