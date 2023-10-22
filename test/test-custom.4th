\ Copyright 2019 nomennescio

s" custom messages" describe#{

  :noname ." Just passed" cr ; ^passed$ !
  :noname ." Just failed" cr ; ^different$ !

  s" short strings" it#{
    <{ s" Hello World!" s# -> s" Hello World!" s# }>
    <{ s" Hello Worlds!" s# -> s" Hello Worlds!" s# }>
  }#
  s" failing compares" it#{
    <{ s" Hello World!" s# -> s" Hello Worlds!" s# }>
    <{ s" Hello Worlds!" s# -> s" Hello Worlds! " s# }>
  }#

  2variable actual$
  2variable expected$

  :noname ." Got '" actual$ 2@ type ." ' as expected" cr ; ^passed$ !
  :noname ." Expected '" expected$ 2@ type ." ', got '" actual$ 2@ type ." '" cr ; ^different$ !

  : &actual 2dup actual$ 2! ;
  : &expected 2dup expected$ 2! ;

  s" short strings" it#{
    <{ s" Hello World!" &actual s# -> s" Hello World!" &expected s# }>
    <{ s" Hello Worlds!" &actual s# -> s" Hello Worlds!" &expected s# }>
  }#
  s" failing compares" it#{
    <{ s" Hello World!" &actual s# -> s" Hello Worlds!" &expected s# }>
    <{ s" Hello Worlds!" &actual s# -> s" Hello Worlds! " &expected s# }>
  }#

}#
