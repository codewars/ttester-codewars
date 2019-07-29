\ Copyright 2019 nomennescio
s" group of tests" describe#{
  s" single test" it#{
    <{ 0 0 -> 0 }>
  }#
  s" double test" it#{
    <{ 0 0 -> 0 }>
    <{ 0 -> 0 }>
  }#
  s" double fail test" it#{
    <{ 0 0 -> 0 }>
    <{ 0 -> 0 0 0 }>
  }#
}#
