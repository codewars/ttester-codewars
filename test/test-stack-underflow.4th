\ Copyright 2019 nomennescio
s" stack underflow" describe#{
  s" single test" it#{
    <{ drop -> 0 }>
  }#
  s" double test" it#{
    <{ drop -> 0 }>
    <{ drop drop -> 0 }>
  }#
  s" double test" it#{
    <{ drop -> 0 0 }>
    <{ drop drop -> 0 0 }>
  }#
  s" double test" it#{
    <{ drop -> 0 0 }>
    <{ drop drop -> 0 }>
  }#
}#
