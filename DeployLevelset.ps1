param (
    $DiskName    
)
Write-Host "Building Levelset"
dotnet LevConv\bin\Debug\net7.0\LevConv.dll -i levelsSrc\baseLevels.json -e levels 
Copy-Item base_disk.d64 $DiskName

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