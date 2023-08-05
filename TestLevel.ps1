param (
    $lev, 
    $isMulti    
)
dotnet LevConv\bin\Debug\net7.0\LevConv.dll -i levelsSrc\baseLevels.json -e levels -t $lev $isMulti -g game.prg
x64sc levels\tmp_test.prg