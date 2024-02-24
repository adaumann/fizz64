# FiZZ Levelbuilder V1.0.2

This FiZZ levelbuilder is designed to make your own levels for the C64 game FiZZ. You can create you own levels, test them immediatly with Vice and export a level pack as D64 disk. Ready to play and distribute.

If you distribute please take credits to the original author: http://fleischgemuese.itch.io/fizz


# Manual

This tool is not a graphical level designer instead you have to create a JSON file containing the whole level set in one file. In order to use the ready-made scripts the file is in "levelsSrc/baseLevels.json"

## Preconditions

You need to following tools first:

* .NET 7 Runtime (https://dotnet.microsoft.com/en-us/download/dotnet-framework)
* Vice Emulator (https://vice-emu.sourceforge.io/)
* CC1541 Tool (https://bitbucket.org/ptv_claus/cc1541/downloads/) - NOT C1541.exe from Vice
* Powershell (included in Windows, for Linux it must be installed separately)

All tools (dotnet.exe, x64sc.exe, cc1541.exe) must be in %Path% environment variable. (See https://www.computerhope.com/issues/ch000549.htm)

## Usage

The levels are in JSON "levelsSrc/baseLevels.json" file defined, for explanation see below

### Test a level

After the JSON files changed a level number "Number" and the Field "IsAllowedTwoPlayers" is relevant, you can run "TestLevel.ps1" command to test it:

Single player: "isallowedTwoPlayers = false"
```
    ./TestLevel 1 false
```

Coop player: "isallowedTwoPlayers = true"
```
    ./TestLevel 1 true
```

After running this a vice window will open and you can test the level.

### Pack a level disk (.D64)

After you finished all levels you need to define the header in the JSON Input file with the correct amount of single/multiplayer levels and the header information, see below.

```
    ./DeployLevelset fizz_levelsetxy_AD.d64
```

You will get a .d64 file with a complete game executable and your levels. Add "_AD" to the end of the filename, this is for the The64, Mini/Maxi to use an accurate diskloader otherwise the loading will fail.

## Level Design

The levels json file is in folder "levelsSrc" -> baseLevels.json. 

### Header information

```
    "HeaderTexts" : [
        "My levels",
        "FancyNickname",
        "Some text",
        "Some more text",
        "Even more text"
    ],
    "MaxSingleLevels": 40,
    "MaxMultiLevels": 30,
```

* Header Texts: must be in following order: Title, Author, Notes1, Notes2, Notes3
* MaxSingleLevels: This has to added manually, number of single player levels
* MaxSingleLevels: This has to added manually, number of multi player levels

### Level design

There are a list of levels, the first level must start with number 0 (each for single and multi player). There are following parts:

* Header
* Rows
* ActionEvents
* Texts

Example:

``` 
        {
            "Number": 2,
            "Name": "Transporter",
            "IsAllowedTwoPlayers": false,
            "BothPlayersMustExit": false,
            "Rows": [
                " 01234567890123456789",
                "0                    ",
                "1                    ",
                "2     .       t      ",
                "3     a       a      ",
                "4 @ aa3        aa  r ",
                "5 aa             aaa ",
                "6     a-------a      ",
                "7                    ",
                "8     ggggggggg      ",
                "9                    ",
                "0         tX         ",
                "1         aa         "
            ],
            "ActionEvents": [
                {
                    "Event": "InitLevel", "Action": "ExitClose",
                    "SenderX": 0, "SenderY": 0,
                    "ReceiverX": 10, "ReceiverY": 10,
                    "Param1": 255, "Param2": 255, "Param3": 255, "Param4": 255
                },
                {
                    "Event": "WaypointEnter", "Action": "PrintText",
                    "SenderX": 5, "SenderY": 2,
                    "ReceiverX": 255, "ReceiverY": 255,
                    "Param1": 1, "Param2": 13, "Param3": 10, "Param4": 255
                },
                {
                    "Event": "WaypointEnter", "Action": "PrintText",
                    "SenderX": 18, "SenderY": 4,
                    "ReceiverX": 255, "ReceiverY": 255,
                    "Param1": 2, "Param2": 17, "Param3": 10, "Param4": 255
                },
                {
                    "Event": "SwitchOn", "Action": "ExitOpen",
                    "SenderX": 18, "SenderY": 4,
                    "ReceiverX": 10, "ReceiverY": 10,
                    "Param1": 255, "Param2": 255, "Param3": 10, "Param4": 255
                },
                {
                    "Event": "SwitchOn", "Action": "LaserCannonOff",
                    "SenderX": 18, "SenderY": 4,
                    "ReceiverX": 5, "ReceiverY": 4,
                    "Param1": 255, "Param2": 255, "Param3": 10, "Param4": 255
                },
                {
                    "Event": "SwitchOff", "Action": "ExitClose",
                    "SenderX": 18, "SenderY": 4,
                    "ReceiverX": 10, "ReceiverY": 10,
                    "Param1": 255, "Param2": 255, "Param3": 10, "Param4": 255
                },
                {
                    "Event": "SwitchOff", "Action": "LaserCannonOn",
                    "SenderX": 18, "SenderY": 4,
                    "ReceiverX": 5, "ReceiverY": 4,
                    "Param1": 255, "Param2": 255, "Param3": 10, "Param4": 255
                },
                {
                    "Event": "WaypointEnter", "Action": "PrintText",
                    "SenderX": 10, "SenderY": 10,
                    "ReceiverX": 255, "ReceiverY": 255,
                    "Param1": 3, "Param2": 18, "Param3": 10, "Param4": 255
                }
            ],
            "Texts": [
                "TRANSPORTER",
                "SHOOT TO SWAP",
                "SWITCH",
                "EXIT"
            ]
        },

```

#### Header

* Number: Level number, please provide starting from 0. Single and multiplayer levels both start with 0
* Name: Any name, not used
* IsAllowedTwoPlayers: if true -> multi player
* BothPlayersMustExit: Only relevant for multiplayer, if true: both players must reach exit else one is enough
  
#### Rows

* These are the level data, it is only possible for all z levels. Overlapping elements are not possible (like a Stone in front of a Door)
* The surrounding numbers are only for conviniant and must remain as is
* The width is 20 chars, height is 12 chars: Important: Must be all filled with the exact size (240 chars in total)

##### Row Elements

| Element Name/PETSCI | Char | Default Value, Remarks |
| -------- | -------- | -------- |
| CHARACTER $40  |@ 
| CHARACTER2 $25 |% | only multiplayer
| BRICK $61 | a
| STONE $62 | b
| SAND $73 | s
| WATER $3d | =
| WATER_UP $27 | '
| WATER_DOWN $26 | &
| WATER_LEFT $7b | ?  
| WATER_RIGHT $7d | ?
| SHIFT_DOWN $59 | Y
| SHIFT_UP $5E | ^
| SHIFT_LEFT $3C | <
| SHIFT_RIGHT $3E | >
| LADDER $68 | h
| ROBE_DOWN $5f  | _ 
| ROBE_UP $2d | -
| ROBE_LEFT $21 | !
| ROBE_RIGHT $7C | \|
| PORTAL $6F | o 
| GRAVPAD_DOWN $32 | 2
| GRAVPAD_UP $38 | 8
| GRAVPAD_LEFT $34 | 4
| GRAVPAD_RIGHT $36 | 6
| MIRROR_LEFT $6e | n 
| MIRROR_RIGHT $6d | m
| GLASS $67 | g
| LASER_TRANSPORT $74 | t
| PUSH_BOX $64 | d 
| PULL_BOX $65 | e
| PORTAL_ACTIVATE_BRICK  $63 | c
| FONTAINE_DOWN $5b | [ | On
| FONTAINE_LEFT $28 | ( | On 
| FONTAINE_RIGHT $29 | ) | On
| FONTAINE_UP $5d | ] | On
| CANNON_DOWN $31 | 1 | On
| CANNON_UP $39 | 9 | On
| CANNON_LEFT $37 | 7 | On
| CANNON_RIGHT $33 | 3 | On
| SWITCH_MANUAL $72 | r | Off, also a waypoint
| DOOR $78 | x | Closed, also a waypoint
| EXIT $58 | X | Closed, also a waypoint
| WAYPOINT $2E | .
| BLOCK $66 | f

#### Action Events

The action events define actions which are fired on certain events. Depending on the action there are sender, receiver and 4 parameters. There are maximal 32 "action events" possible

Example:

```
    {
        "Event": "SwitchOn", "Action": "ExitOpen",
        "SenderX": 18, "SenderY": 4,
        "ReceiverX": 10, "ReceiverY": 10,
        "Param1": 255, "Param2": 255, "Param3": 255, "Param4": 255
    },
```

Means: If the character switches a switch on, at position x=18, y=4 the receiver exit element at position x=10, y=10 will get the action "ExitOpen". Parameters are not relevant for this action, leave to 255

##### Events

| Element Name | Description |
| -------- | -------- |
| InitLevel | Level started |
| SwitchOn | Switch is on |
| SwitchOff | Switch is off |
| WaypointEnter | Waypoint entered, a switch, door or exit can also be waypoint | 
| WaypointLeave | Waypoint left, a switch, door or exit can also be waypoint |

##### Actions

| Element Name | Description | Parameters |
| -------- | -------- | ------- |
|    DoorOpen | Open a door | Needs receiver, No Params
|    DoorClose | Close a door | Needs receiver, No Params
|    ExitOpen | Open a exit | Needs receiver, No Params
|    ExitClose | Close a exit | Needs receiver, No Params
|    PrintText | Print a text | No need a receiver, Param1 = TextId from element "Texts", Param2 = Position (to center calc: 20 - length / 2), Param3 = Duration (typically 10)
|    ClearText | Clear Text | No need a receiver
|    LasercannonOn | Activate laser cannon | Needs receiver, No Params
|    LasercannonOff | Deactivate laser cannon | Needs receiver, No Params
|    FontaineOn | Activate water fontaine | Needs receiver, No Params
|    FontaineOff | Deactivate water fontaine | Needs receiver, No Params
|    SetGrav | Set gravity (for character, stone, block) | Param1= 1,up, 7,down, 3,left, 5,right
|    SwitchOn | Activate switch | Needs receiver, No Params
|	 SwitchOff | Deactivate switch | Needs receiver, No Params 
|    SetGravBulk | Set gravity for ALL elements of a type stone, block | No receiver needed, Param1 = 1,up, 7,down, 3,left, 5,right 

If require more actions please contact me, this need to be programmed.

##### Texts

These are texts you can display with "PrintText" action, the first text is always shown when starting level. Use Uppercase

