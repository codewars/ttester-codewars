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

variable ^passed
variable ^nresults
variable ^different

: passed$  ." Test Passed" cr ;
: different$ ." Expected "
  RESULTS @ 0 +do EXPECTED-RESULTS i cells + @ . loop
  ." , got "
  RESULTS @ 0 +do ACTUAL-RESULTS i cells + @ . loop
  cr ;
: nresults$ ." Wrong number of results, expected " depth START-DEPTH @ - .
  ." , got " ACTUAL-DEPTH @ START-DEPTH @ - . cr ;

' passed$ ^passed !
' nresults$ ^nresults !
' different$ ^different !

: <{ T{ ;
: }>
  depth ACTUAL-DEPTH @ = if
    depth START-DEPTH @ > if
      depth START-DEPTH @ - dup RESULTS ! 0 +do
        dup EXPECTED-RESULTS i cells + !
        ACTUAL-RESULTS i cells + @ <> DIFFERENCES +!
      loop
      DIFFERENCES @ if
        failed# ^different @ execute
      else
        passed# ^passed @ execute
      then
    then
  else
    failed# ^nresults @ execute
  then
  EMPTY-STACK
  F} ;

3037000493 constant #m \ prime number < sqrt (2^63-1)
53 constant #p         \ prime number
: c# { hash pow c -- hash' pow' } c pow * hash + #m mod pow #p * #m mod ;       \ polynomial rolling hash function, single char
: s# { c-addr u -- hash } 0 1 c-addr u 0 +do { s } s c@ c# s char+ loop 2drop ; \ string hash