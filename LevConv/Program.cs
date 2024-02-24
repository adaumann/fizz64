using LevConv.Model;
using LevConv.Services;

namespace LevConv
{
    internal class Program
    {
        static void Main(string[] args)
        {
            //var set = SampleData();
            //FileService.SaveLevelSet("sample.json", set);
            //return;
            var importFile = "";
            var exportFolder = "";
            var gameFile = "";
            int testLevelNumber = -1;
            bool doTest = false;
            bool isMulti = false;
            for (int i = 0; i < args.Length; i++)
            {
                if (args[i] == "-i")
                {
                    importFile = args[i + 1];
                }
                if (args[i] == "-e")
                {
                    exportFolder = args[i + 1];
                }

                if (args[i] == "-g")
                {
                    gameFile = args[i + 1];
                }
                if (args[i] == "-t")
                {
                    testLevelNumber = int.Parse(args[i + 1]);
                    isMulti = bool.Parse(args[i + 2]);
                    doTest = true;
                }
            }

            if ((doTest && testLevelNumber >= 0 && !string.IsNullOrEmpty(importFile) && !string.IsNullOrEmpty(exportFolder) && !string.IsNullOrEmpty(gameFile)) ||
                (!doTest && !string.IsNullOrEmpty(importFile) && !string.IsNullOrEmpty(exportFolder)))
            {
                Console.WriteLine($"Import File: {importFile}");
                Console.WriteLine($"Export Folder: {exportFolder}");
                Console.WriteLine($"Game File: {gameFile}");
                Console.WriteLine($"Level: {testLevelNumber}");
                Console.WriteLine($"isMulti: {isMulti}");
                var levelSet = FileService.LoadLevelSet(importFile);
                if (levelSet == null)
                {
                    Console.WriteLine("Error loading level set");
                    return;
                }
                ExportService.ExportAsBinary(levelSet, exportFolder, true);
                if (doTest)
                {
                    ExportService.BuildTestExecutable(testLevelNumber, isMulti, exportFolder, gameFile, true);

                }
            }
            else
            {
                Console.WriteLine("Usage: LevConv -i <import file> -e <export folder> [-t <level> <2player>] [-l]  [-g <game file>]");
                Console.WriteLine(" -i : Import File as Json");
                Console.WriteLine(" -e : Export folder containing binary levels to be transferred on disk");
                Console.WriteLine(" -t : Build a test PRG file with level and single/multi flag, output in test.prg");
                Console.WriteLine(" -g : Base game file for testing, with -t flag");
            }

        }

        static LevelSet SampleData() 
        {
            var set = new LevelSet();
            set.HeaderTexts = new List<string>()
            {
                "Sample",
                "username",
                "notes1",
                "notes2",
                "notes3"
            };
            set.MaxSingleLevels = 1;
            set.MaxMultiLevels = 0;
            set.Levels = new List<Level>()
            {
                new Level()
                {
                    BothPlayersMustExit = true, IsAllowedTwoPlayers = true, Name = "Level 1", Number = 1,
                    Rows = new List<string>()
                    {
                        " 01234567890123456789",
                        "0xxxxxxxxxxxxxxxxxxxx",
                        "1x                  x",
                        "2x                  x",
                        "3x                  x",
                        "4x                  x",
                        "5x                  x",
                        "6x                  x",
                        "7x                  x",
                        "8x                  x",
                        "9x                  x",
                        "0x                  x",
                        "1xxxxxxxxxxxxxxxxxxxx",
                    },
                    ActionEvents = new List<ActionEvent>()
                    {
                        new ActionEvent()
                        {
                            Event = EventType.InitLevel,
                            Action = ActionType.DoorOpen,
                            SenderX = 0,
                            SenderY = 0,
                            ReceiverX = 0,
                            ReceiverY = 0,
                            Param1 = 0,
                            Param2 = 0,
                            Param3 = 0,
                            Param4 = 0,
                        },
                    },
                    Texts = new List<string>()
                    {
                        "Hello World","Hello Again"
                    }
                }
            };
            return set;
        }
    }
}