\ ttester extension for Codewars
decimal
s" test/ttester.fs" included

: #ms ( dmicroseconds -- len c-addr ) <# # # # [char] . hold #s #> ;

: describe#{ ( len c-addr -- ) cr ." <DESCRIBE::>" type cr utime ;
: it#{ ( len c-addr -- ) cr ." <IT::>" type cr utime ;
: }# ( -- ) utime cr ." <COMPLETEDIN::>" 2swap d- #ms type ."  ms" cr ;

: failed# ( -- ) cr ." <FAILED::>" ;
: passed# ( -- ) cr ." <PASSED::>" ;

create EXPECTED-RESULTS 32 cells allot
variable RESULTS
variable DIFFERENCES

: <{ T{ ;
: }>
  depth ACTUAL-DEPTH @ = if
    depth START-DEPTH @ > if
      depth START-DEPTH @ - dup RESULTS ! 0 do
        dup EXPECTED-RESULTS i cells + !
        ACTUAL-RESULTS i cells + @ <> DIFFERENCES +!
      loop
      DIFFERENCES @ if
        failed# ." Expected "
        RESULTS @ 0 do EXPECTED-RESULTS i cells + @ . loop
        ." , got "
        RESULTS @ 0 do ACTUAL-RESULTS i cells + @ . loop
        cr
        EMPTY-STACK
      else
        passed# ." Test Passed" cr
      then
    then
  else
    failed# ." Wrong number of results, expected " ACTUAL-DEPTH @ . ." , got " depth . cr EMPTY-STACK
  then
  F} ;
