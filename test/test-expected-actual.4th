\ Copyright 2019 nomennescio
s" Expected results and actual results tests" describe#{
  s" Match" it#{
     <{ 0 1 2 3 -> 0 1 2 3 }>
  }#
  s" Mismatch" it#{
     <{ 0 1 2 3 -> 4 5 6 7 }>
  }#
}#