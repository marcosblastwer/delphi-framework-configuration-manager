unit Base.Objects.Types;

interface

type
  IIterator = interface(IInterface)
    ['{47206F10-4178-404F-89C0-AB9C2C66F626}']
    procedure Reset;
    function CurrentItem: IInterface;
    function Eof: Boolean;
    function First: IInterface;
    function Get(const Index: Integer): IInterface;
    function GetIndex: Integer;
    function Last: IInterface;
    function Next: Boolean;
  end;

implementation

end.
