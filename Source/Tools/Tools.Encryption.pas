unit Tools.Encryption;

interface

type
  Encryption = class
  public
    class function Encrypt(const Value: String): String;
    class function Decrypt(const Value: String): String;
    class function Md5(const Filename: String): String;
  end;

implementation

uses
  //IdHash,
  //IdHashMessageDigest,
  //System.Classes,
  System.SysUtils;

const
  ENCRYPTION_KEY = 'BLASTWER';

{ Encryption }

class function Encryption.Decrypt(const Value: String): String;
var
  Dest, Key: String;
  KeyLen, KeyPos, OffSet, SrcPos, SrcAsc, TmpSrcAsc: Integer;
begin
  if (Value = EmptyStr) Then
  begin
    Result:= EmptyStr;
    Exit;
  end;
  Key := ENCRYPTION_KEY;
  Dest := '';
  KeyLen := Length(Key);
  KeyPos := 0;
  OffSet := StrToInt('$' + copy(Value,1,2));
  SrcPos := 3;
  repeat
    SrcAsc := StrToInt('$' + copy(Value,SrcPos,2));
    if KeyPos < KeyLen then
      KeyPos := KeyPos + 1
    else
      KeyPos := 1;
    TmpSrcAsc := SrcAsc Xor Ord(Key[KeyPos]);
    if TmpSrcAsc <= OffSet then
      TmpSrcAsc := 255 + TmpSrcAsc - OffSet
    else
      TmpSrcAsc := TmpSrcAsc - OffSet;
    Dest := Dest + Chr(TmpSrcAsc);
    OffSet := SrcAsc;
    SrcPos := SrcPos + 2;
  until (SrcPos >= Length(Value));
  Result:= Dest;
end;

class function Encryption.Encrypt(const Value: String): String;
var
  Dest, Key: String;
  KeyLen, KeyPos, OffSet, Range, SrcPos, SrcAsc: Integer;
begin
  if (Value = EmptyStr) Then
  begin
    Result:= EmptyStr;
    Exit;
  end;
  Key := ENCRYPTION_KEY;
  Dest := '';
  KeyLen := Length(Key);
  KeyPos := 0;
  Range := 256;
  Randomize;
  OffSet := Random(Range);
  Dest := Format('%1.2x',[OffSet]);
  for SrcPos := 1 to Length(Value) do
  begin
    SrcAsc := (Ord(Value[SrcPos]) + OffSet) Mod 255;
    if KeyPos < KeyLen then
      KeyPos := KeyPos + 1
    else
      KeyPos := 1;
    SrcAsc := SrcAsc Xor Ord(Key[KeyPos]);
    Dest := Dest + Format('%1.2x',[SrcAsc]);
    OffSet := SrcAsc;
  end;
  Result:= Dest;
end;

class function Encryption.Md5(const Filename: String): String;
{var
  IdMD5: TIdHashMessageDigest5;
  Stream: TFileStream;}
begin
{ IdMD5 := TIdHashMessageDigest5.Create;
  try
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    Result := IdMD5.HashStreamAsHex(Stream)
  finally
    FreeAndNil(Stream);
    FreeAndNil(IdMD5);
  end; }
end;

end.
