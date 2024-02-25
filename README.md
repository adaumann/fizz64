# FiZZ - A platform puzzle game for C64

Release: https://fleischgemuese.itch.io/fizz

# Development

The game was developed with the cross-plattform IDE/Compiler Turbo Rascal (www.turborascal.com) 

# Installation

* Download TRSE: https://github.com/leuat/TRSE 
* Download VICE: https://vice-emu.sourceforge.io/
* Download Exomizer: https://csdb.dk/release/?id=198340
* Download CC1541: https://csdb.dk/release/?id=230166&show=notes
* Download Tinycrunch: https://csdb.dk/release/?id=168629&show=summary
* Download .NET7: https://dotnet.microsoft.com/en-us/download/dotnet/7.0
* Use Powershell under Windows

Open TRSE -> Tools -> Settings: 

C64 Emulator: Path to x64sc.exe
Exomizer: Path to exomizer.exe
Tinycrunch: Path to tinycrunch tc_encode.py

# Running game without loading levels (only one demo level is available)

a) Development version without level loading
For development open Fizz project and Project Settings:
* Project output type: prg
* Target file: game.ras

Start with Run (c-r) 

## Run a test level via commandline

You can edit the levelsSrc/baseLevels.json file and run test TestLevel command to test one level. See [LevelBuilder Help](FiZZ Levelbuilder Manual.md)

* Build levels, you can use TestLevel.ps1 command to test levels: i.e. Testlevel 1 false (c64 emulator should show up)

# Development disk version
For release  open Fizz project and Project Settings:
* Project output type: d64
* Target file: boot.ras

* Build with "Build all"
* Run Powershell script from commandline cut.ps1
* Run initial to build boot_disk1.d64: Press Run (c-r)
* Build levels, you can use TestLevel.ps1 command: Testlevel 1 false (ignore the c64 emulator)
* Build disk with command: disk.ps1

-> The D64 should now be ready