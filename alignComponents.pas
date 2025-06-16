{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit alignComponents;

{$warn 5023 off : no warning about unused units}
interface

uses
  alignComponentsImpl, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('alignComponentsImpl', @alignComponentsImpl.Register);
end;

initialization
  RegisterPackage('alignComponents', @Register);
end.
