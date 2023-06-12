param (
    $lev, 
    $isMulti    
)
LevConv\bin\Debug\net7.0\LevConv.exe -i levelsSrc\baseLevels.json -e levels -t $lev $isMulti -g game.prg
x64sc levels\tmp_test.prg