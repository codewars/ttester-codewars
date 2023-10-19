\ ttester extension for Codewars
\ Copyright 2019-2023 nomennescio
decimal
s" test/ttester.fs" included

: #ms ( dmicroseconds -- c-addr len ) <# # # # [char] . hold #s #> ;

: describe#{ ( c-addr len -- ) cr ." <DESCRIBE::>" type cr utime ;
: it#{ ( c-addr len -- ) cr ." <IT::>" type cr utime ;
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
  0 RESULTS @ -do EXPECTED-RESULTS i 1- cells + @ . 1 -loop
  ." , got "
  0 RESULTS @ -do ACTUAL-RESULTS i 1- cells + @ . 1 -loop
  cr ;
: nresults$ ." Wrong number of results, expected " depth START-DEPTH @ - .
  ." , got " ACTUAL-DEPTH @ START-DEPTH @ - dup 0< if negate ." a " . ." cell stack underflow" else . then cr ;

' passed$ ^passed !
' nresults$ ^nresults !
' different$ ^different !

: <{ T{ ;
: ->  depth dup ACTUAL-DEPTH !
   START-DEPTH @ >= if
     depth START-DEPTH @ - 0 +do ACTUAL-RESULTS i cells + ! loop
   else
     START-DEPTH @ depth - -1 +do 0 loop
   then
   F-> ;
: }>
  depth ACTUAL-DEPTH @ = if
    depth START-DEPTH @ > if
      0 DIFFERENCES !
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
  F}
  EMPTY-STACK ;

3037000493 constant #m \ prime number < sqrt (2^63-1)
53 constant #p         \ prime number
: c# { hash pow c -- hash' pow' } c pow * hash + #m mod pow #p * #m mod ;       \ polynomial rolling hash function, single char
: s# { c-addr len -- hash } 0 1 c-addr len 0 +do { s } s c@ c# s char+ loop 2drop ; \ string hash