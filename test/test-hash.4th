\ Copyright 2019 nomennescio
s" string hash" describe#{
  s" short strings" it#{
    <{ s" Hello World!" s# -> s" Hello World!" s# }>
    <{ s" Hello Worlds!" s# -> s" Hello Worlds!" s# }>
  }#
  s" failing compares" it#{
    <{ s" Hello World!" s# -> s" Hello Worlds!" s# }>
    <{ s" Hello Worlds!" s# -> s" Hello Worlds! " s# }>
  }#
  s" failing compares with custom messages" it#{
    <{ s" Hello World!" 2dup ." Actual: '" type ." '" s# -> s" Hello Worlds!" 2dup ." , Expected: '" type ." '" s# }>
    <{ s" Hello Worlds!" 2dup ." Actual: '" type ." '" s# -> s" Hello Worlds! " 2dup ." , Expected: '" type ." '" s# }>
  }#
}#
