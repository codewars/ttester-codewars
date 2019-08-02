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
}#
