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

\ prefill stack to prevent runtime stack underflow error
0

s" simple underflow" describe#{
  s" single test" it#{
    <{ drop -> 0 }>
  }#
}#

drop

balance$
reset-stacks

\ prefill stacks to prevent runtime stack underflow error
12  34  56  78
12e 34e 56e 78e

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

  s" float test" it#{
    <{ fdrop -> 0e }>
  }#
  s" double float test" it#{
    <{ fdrop -> 0e }>
    <{ fdrop fdrop -> 0e }>
  }#
  s" double float test" it#{
    <{ fdrop -> 0e 0e }>
    <{ fdrop fdrop -> 0e 0e }>
  }#
  s" double float test" it#{
    <{ fdrop -> 0e 0e }>
    <{ fdrop fdrop -> 0e }>
  }#
}#

 drop  drop  drop  drop
fdrop fdrop fdrop fdrop

balance$
