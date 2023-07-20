using System.Diagnostics;
using Microsoft.VisualBasic.CompilerServices;

namespace LevConv.Model;

public class LevelSet
{
    public ICollection<Level> Levels { get; set; }
}

public class Level
{
    public const int DimX = 20;
    public const int DimY = 12;

    public int Number { get; set; }

    public string? Name { get; set; }

    public bool IsAllowedTwoPlayers { get; set; }

    public bool BothPlayersMustExit { get; set; }

    public ICollection<string> Rows { get; set; } = new List<string>();

    public ICollection<ActionEvent> ActionEvents { get; set; } = new List<ActionEvent>();

    public ICollection<string> Texts { get; set; } = new List<string>();

    public char GetElementAtPos(int pos)
    {
        var x = (int)Math.Floor((decimal)pos / DimX);
        var y = pos % DimY;

        return Rows.ElementAt(y)[x];
    }
}

public class ActionEvent
{
    public EventType Event { get; set; }

    public ActionType Action { get; set; }

    public int SenderX { get; set; }

    public int SenderY { get; set; }

    public int ReceiverX { get; set; }

    public int ReceiverY { get; set; }

    public int Param1 { get; set; }

    public int Param2 { get; set; }

    public int Param3 { get; set; }

    public int Param4 { get; set; }
}

public enum EventType
{
    InitLevel=0, 
    SwitchOn=1, 
    SwitchOff=2, 
    WaypointEnter=3, 
    WaypointLeave=4,
}

public enum ActionType
{
    DoorOpen=1,
    DoorClose=2,
    ExitOpen=3,
    ExitClose=4,
    PrintText=5,
    ClearText=6,
    LasercannonOn=7,
    LasercannonOff=8,
    FontaineOn=9,
    FontaineOff=10,
	SetGrav=11,
	SwitchOn=12,
	SwitchOff=13,
	SetGravBulk=14
}
