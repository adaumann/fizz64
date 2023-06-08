  $stream = [System.IO.File]::OpenRead("game.prg")
  $barr = New-Object byte[] 65535
  $bytesRead = $stream.Read($barr,0, 50944)
  $ostream = [System.IO.File]::OpenWrite("game_s.prg")
  $ostream.Write($barr,2,$bytesRead);
  $ostream.close();
  $stream.close();

