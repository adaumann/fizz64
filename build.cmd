cd C:\Users\mail\OneDrive\Source\pool64
del disk.d64
c1541.exe -format disk1,09 d64 disk.d64 -attach disk.d64 -write boot.prg boot -write test.prg test -write game.prg fizz -write levels\lev0
x64sc.exe disk.d64