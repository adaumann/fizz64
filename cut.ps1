  $stream = [System.IO.File]::OpenRead("game.prg")
  $barr = New-Object byte[] 65535
  $bytesRead = $stream.Read($barr,0, 50944)
  $ostream = [System.IO.File]::OpenWrite("game_s.prg")
  $ostream.Write($barr,2,$bytesRead);
  $ostream.close();
  $stream.close();

  PrintText(@EXIT_CLOSED_START,#txtExitClosed);

x {aaaaaa  a  a  aaa  ^a aa  a  aa    aa6    aaa  aa      aaa a6   1[12    ^ ^Yaa     o   ^      ^Yaa&     ^         ^Yaa&    ^          ^Yaa&            h    aa& 4------====hh   aa&m   n   b@   =  4aa X x===ss rs8 h o aaaa    aaaaaaaaaaaaaa
