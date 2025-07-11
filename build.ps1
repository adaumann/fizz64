param (
    $DiskName    
)

del "fizz" -ErrorAction Ignore
del "a" -ErrorAction Ignore
del "b" -ErrorAction Ignore
del "s" -ErrorAction Ignore
del "t1" -ErrorAction Ignore        
del "t2" -ErrorAction Ignore

del $DiskName -ErrorAction Ignore
Write-Host "Building Levelset"
dotnet LevConv\bin\Debug\net7.0\LevConv.dll -i levelsSrc\baseLevels.json -e levels 

exomizer.exe sfx `$0810 boot.prg -o fizz -n 

python ./tc_encode.py -i intro.prg a 
# Add 0x00 0x09 to the beginning of file "a"
# $bytes = [byte[]](0x00, 0x09) + [System.IO.File]::ReadAllBytes("a")
# [System.IO.File]::WriteAllBytes("a", $bytes)

$stream = [System.IO.File]::OpenRead("game.prg")
$barr = New-Object byte[] 65535
$bytesRead = $stream.Read($barr,0, 50944)
$ostream = [System.IO.File]::OpenWrite("b")
$ostream.Write($barr,0,$bytesRead);
$ostream.close();
$stream.close();

# python ./tc_encode.py -i game.prg b 
# $bytes = [byte[]](0x00, 0x09) + [System.IO.File]::ReadAllBytes("b")
# [System.IO.File]::WriteAllBytes("b", $bytes)


# # Trim the first two bytes from sounds.prg and save to sounds_c.bin
$sounds = Get-Content -Path "sounds/sounds.prg" -Encoding Byte
$soundsTrimmed = $sounds[0..($sounds.Length - 1)]
[System.IO.File]::WriteAllBytes("s", $soundsTrimmed)

# Trim the first two bytes from fizz_intro_2000.sid and save to fizz_intro2000_c.bin
$sounds = Get-Content -Path "music/fizz_intro_2000.sid" -Encoding Byte
$soundsTrimmed = $sounds[126..($sounds.Length - 1)]
[System.IO.File]::WriteAllBytes("t1", $soundsTrimmed)
$bytes = [byte[]](0x00, 0x20) + [System.IO.File]::ReadAllBytes("t1")
[System.IO.File]::WriteAllBytes("t1", $bytes)


# Trim the first two bytes from fizz_background2_20.sid and save to fizz_background2_20_c.bin
$sounds = Get-Content -Path "music/fizz_background2_20.sid" -Encoding Byte
$soundsTrimmed = $sounds[126..($sounds.Length - 1)]
[System.IO.File]::WriteAllBytes("t2", $soundsTrimmed)
$bytes = [byte[]](0x00, 0x20) + [System.IO.File]::ReadAllBytes("t2")
[System.IO.File]::WriteAllBytes("t2", $bytes)


cc1541.exe -n fizz -d 19 -w "fizz" -f fizz $DiskName
cc1541.exe -n fizz -d 19 -w "a" -f "a" $DiskName
cc1541.exe -n fizz -d 19 -w "b" -f "b" $DiskName    
cc1541.exe -n fizz -d 19 -w "s" -f "s" $DiskName 
cc1541.exe -n fizz -d 19 -w "t1" -f "t1" $DiskName 
cc1541.exe -n fizz -d 19 -w "t2" -f "t2" $DiskName 


cc1541.exe -n fizz -d 19 -w ".\levels\l" -f "l" $DiskName

Write-Host "Adding Levels"
cc1541.exe -n fizz -d 19 -w ".\levels\l" -f "l" $DiskName

Get-ChildItem -Path ".\levels\s*" |

Foreach-Object {
    cc1541.exe -n fizz -d 19 -w $_.FullName -f $_.BaseName $DiskName
    Write-Host $_.BaseName
}

Get-ChildItem -Path ".\levels\m*" |

Foreach-Object {
    cc1541.exe -n fizz -d 19 -w $_.FullName -f $_.BaseName $DiskName
    Write-Host $_.BaseName
}

Write-Host "Done, your level disk is ready"