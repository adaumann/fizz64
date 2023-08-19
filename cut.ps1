  $stream = [System.IO.File]::OpenRead("game.prg")
  $barr = New-Object byte[] 65535
  $bytesRead = $stream.Read($barr,0, 50944)
  $ostream = [System.IO.File]::OpenWrite("game_s.prg")
  $ostream.Write($barr,2,$bytesRead);
  $ostream.close();
  $stream.close();

  $stream = [System.IO.File]::OpenRead("sounds/sounds.prg")
  $barr = New-Object byte[] 65535
  $bytesRead = $stream.Read($barr,0, 839)
  $ostream = [System.IO.File]::OpenWrite("sounds/_sounds.prg")
  $ostream.Write($barr,2,$bytesRead);
  $ostream.close();
  $stream.close();


  # $binaryData = [Byte[]] (0x00, 0xE0)
  # [IO.File]::WriteAllBytes("./music/fizz_ingame_e000.bin", $binaryData)
  # cmd /c copy /b music\fizz_ingame_e000.bin+music\_fizz_ingame_e000.dat music\fizz_ingame_e000.bin 

  # $binaryData = [Byte[]] (0x00, 0x20)
  # [IO.File]::WriteAllBytes("./music/fizz_intro_2000.bin", $binaryData)
  # cmd /c copy /b music\fizz_intro_2000.bin+music\_fizz_intro_2000.dat music\fizz_intro_2000.bin 
