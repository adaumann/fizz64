using System.Runtime.Serialization;
using System.Text;
using LevConv.Model;
using System.Text.Json;

namespace LevConv.Services
{
    public static class ExportService
    {
        public static void BuildTestExecutable(int index, bool isMulti, string folder, string basePrgFile, bool incHeader)
        {
            using BinaryWriter bwWriter = new BinaryWriter(File.Open(@folder + @"\tmp_test.prg", FileMode.Create), Encoding.ASCII, false);
            // Reading binary data from file, replacing binary data at 0x1c00 with exported binary level data file and writing it back to file
            using BinaryReader brReader1 = new BinaryReader(File.Open(basePrgFile, FileMode.Open), Encoding.ASCII, false);
            {
                var bytes = brReader1.ReadBytes(0x1401);
                bwWriter.Write(bytes);
                var fileName = folder + "\\s" + index.ToString("X");
                if (isMulti)
                {
                    fileName = folder + "\\m" + index.ToString("X");
                }
                var data = File.ReadAllBytes(fileName);
                var s = 0;
                if(incHeader)
                    s = 2;
                for (int i = s; i < data.Length; i++)
                {
                    bwWriter.Write((byte)data[i]);
                }
                var fill = 0x1801 - 0x1401 - data.Length + s;
                for (int i = 0; i < fill; i++)
                {
                    bwWriter.Write((byte)255);
                }
            }
            brReader1.Close();
            var length = File.ReadAllBytes(basePrgFile).Length;
            using BinaryReader brReader2 = new BinaryReader(File.Open(basePrgFile, FileMode.Open), Encoding.ASCII, false);
            {
                brReader2.ReadBytes(0x1801);
                var bytes = brReader2.ReadBytes(length - 0x1801);
                bwWriter.Write(bytes);
            }
            bwWriter.Close();
        }

        public static void ExportAsBinary(LevelSet levelSet, string folder, bool incHeader)
        {
            foreach (var level in levelSet.Levels)
            {
                string fileName;
                if (level.IsAllowedTwoPlayers)
                {
                    fileName = folder + "\\m" + level.Number.ToString("X");
                }
                else
                {
                    fileName = folder + "\\s" + level.Number.ToString("X");
                }

                using BinaryWriter bwWriter = new BinaryWriter(File.Open(fileName, FileMode.Create), Encoding.ASCII, false);
                {
                    if(incHeader)
                    {
                        bwWriter.Write((byte)0x0);
                        bwWriter.Write((byte)0x1c);
                    }
                    // Level map
                    var i = 0;
                    foreach (var row in level.Rows)
                    {
                        if (i > 0)
                        {
                            var j = 0;
                            foreach (var field in row.ToCharArray())
                            {
                                if (j > 0)
                                {
                                    bwWriter.Write((byte)field);
                                }
                                j++;
                            }
                        }
                        i++;
                    }
                    bwWriter.Write((byte)0x0);
                    // Action events
                    for (int a = 0; a < 32; a++)
                    {
                        var actionEvent = level.ActionEvents.ElementAtOrDefault(a);
                        if (actionEvent != null)
                        {
                            var senderPos = 0xff;
                            var receiverPos = 0xff;
                            if(actionEvent.SenderX != 0xff && actionEvent.SenderY != 0xff) 
                                senderPos = GetPos(actionEvent.SenderX, actionEvent.SenderY);
                            if(actionEvent.ReceiverX != 0xff && actionEvent.ReceiverY != 0xff) 
                                receiverPos = GetPos(actionEvent.ReceiverX, actionEvent.ReceiverY);
                            bwWriter.Write((byte)actionEvent.Event);
                            bwWriter.Write((byte)actionEvent.Action);
                            bwWriter.Write((byte)senderPos);
                            bwWriter.Write((byte)receiverPos);
                            bwWriter.Write((byte)actionEvent.Param1);
                            bwWriter.Write((byte)actionEvent.Param2);
                            bwWriter.Write((byte)actionEvent.Param3);
                            bwWriter.Write((byte)actionEvent.Param4);
                        }
                        else
                        {
                            for (int b = 0; b < 8; b++)
                            {
                                bwWriter.Write((byte)255);
                            }
                        }
                    }
                    // Flags
                    bwWriter.Write(level.BothPlayersMustExit);
                    // Strings
                    var pos = 0x1df2;
                    pos += (level.Texts.Count * 2);
                    foreach (var str in level.Texts)
                    {
                        var bytes = BitConverter.GetBytes(pos);
                        bwWriter.Write((byte)bytes[0]);
                        bwWriter.Write((byte)bytes[1]);
                        pos = pos + str.Length + 1;
                    }
                    foreach (var str in level.Texts)
                    {
                        foreach (var field in str.ToCharArray())
                        {
                            bwWriter.Write((byte)field);
                        }
                        bwWriter.Write((byte)0x0);
                    }
                }
            }
        }

        private static int GetPos(int x, int y)
        {
            return (y * Level.DimX) + x;
        }
    }
}