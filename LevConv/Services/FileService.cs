using LevConv.Model;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace LevConv.Services;

public static class FileService
{
    /// <summary>
    /// Load a level set from a json file
    /// </summary>
    /// <param name="jsonFile"></param>
    /// <returns></returns>
    public static LevelSet? LoadLevelSet(string jsonFile)
    {
        var json = File.ReadAllText(jsonFile);
        var options = new JsonSerializerOptions();
        options.Converters.Add(new JsonStringEnumConverter()); 
        var levelSet = JsonSerializer.Deserialize<LevelSet>(json, options);
        return levelSet;
    }

    public static void SaveLevelSet(string jsonFile, LevelSet levelSet)
    {
        var options = new JsonSerializerOptions();
        options.Converters.Add(new JsonStringEnumConverter()); 
        var json = JsonSerializer.Serialize(levelSet, options);
        File.WriteAllText(jsonFile, json);
    }
}