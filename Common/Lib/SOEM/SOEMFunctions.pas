unit SOEMFunctions;

interface

uses
    SOEMLIB, SOEMParams, Windows;

function SDOwrite(Slave: Integer; Index: Word; SubIndex: Byte; const Value: Byte; UseCA: Boolean = False): Integer; overload;

function SDOWrite(Slave: Integer; Index: Word; SubIndex: Byte; const Value: Word; UseCA: Boolean = False): Integer; overload;

function SDOWrite(Slave: Integer; Index: Word; SubIndex: Byte; const Value: DWord; UseCA: Boolean = False): Integer; overload;

function SDORead(Slave: Integer; Index: Word; SubIndex: Byte; var Value: Byte; UseCA: Boolean = False): Integer; overload;

function SDORead(Slave: Integer; Index: Word; SubIndex: Byte; var Value: WORD; UseCA: Boolean = False): Integer; overload;

function SDORead(Slave: Integer; Index: Word; SubIndex: Byte; var Value: DWORD; UseCA: Boolean = False): Integer; overload;




implementation

function SDOwrite(Slave: Integer; Index: Word; SubIndex: Byte; const Value: Byte; UseCA: Boolean): Integer;
begin
    Result := SOEM_SDOwrite8(Slave, Index, SubIndex, UseCA, SizeOf(Value), @Value);
end;

function SDOWrite(Slave: Integer; Index: Word; SubIndex: Byte; const Value: Word; UseCA: Boolean): Integer;
begin
    Result := SOEM_SDOwrite16(Slave, Index, SubIndex, UseCA, SizeOf(Value), @Value);
end;

function SDOWrite(Slave: Integer; Index: Word; SubIndex: Byte; const Value: DWord; UseCA: Boolean): Integer;
begin
    Result := SOEM_SDOwrite32(Slave, Index, SubIndex, UseCA, SizeOf(Value), @Value);
end;

function SDORead(Slave: Integer; Index: Word; SubIndex: Byte; var Value: Byte; UseCA: Boolean): Integer;
var
    dataSize: Integer;
begin
    dataSize := SizeOf(Byte);
    Result := SOEM_SDOread(Slave, Index, SubIndex, UseCA, @dataSize, @Value);
end;

function SDORead(Slave: Integer; Index: Word; SubIndex: Byte; var Value: WORD; UseCA: Boolean): Integer;
var
    dataSize: Integer;
begin
    dataSize := SizeOf(Word);
    Result := SOEM_SDOread(Slave, Index, SubIndex, UseCA, @dataSize, @Value);
end;

function SDORead(Slave: Integer; Index: Word; SubIndex: Byte; var Value: DWORD; UseCA: Boolean): Integer;
var
    dataSize: Integer;
begin
    dataSize := SizeOf(DWord);
    Result := SOEM_SDOread(Slave, Index, SubIndex, UseCA, @dataSize, @Value);
end;

end.

