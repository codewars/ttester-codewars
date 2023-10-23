\ Copyright 2019-2023 nomennescio

variable sp* variable fp*
: reset-stacks clearstack ( fclearstack ) sp@ sp* ! fp@ fp* ! ;

: ?balance$ ( ? s# s* -- ) type ."  stack " if ." balanced" else ." unbalanced" then cr ;
:  balance$ ( -- ) sp@ sp* @ = s" cell "  ?balance$ fp@ fp* @ = s" float" ?balance$ ;

reset-stacks
balance$

0 0e \ force unbalance

balance$
reset-stacks

s" no underflow" describe#{
  s" single test" it#{
    <{ 0 -> 0 }>
  }#
}#

balance$
reset-stacks

s" simple underflow" describe#{
  s" single test" it#{
    <{ -> 0 }>
  }#
}#

balance$
reset-stacks

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

balance$
