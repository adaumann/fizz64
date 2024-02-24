Get-ChildItem -Path ".\levels\s*" -Exclude "s*_c" |

Foreach-Object {

    cc1541.exe -n fizz -d 19 -w $_.FullName -f $_.BaseName boot_disk1.d64 
    Write-Host $_.BaseName

}

Get-ChildItem -Path ".\levels\m*" -Exclude "m*_c" |

Foreach-Object {

    cc1541.exe -n fizz -d 19 -w $_.FullName -f $_.BaseName boot_disk1.d64 
    Write-Host $_.BaseName

}