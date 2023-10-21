\ ttester extension for Codewars
\ Copyright 2019-2023 nomennescio
decimal

: #ms ( dmicroseconds -- c-addr len ) <# # # # [char] . hold #s #> ;

: describe#{ ( c-addr len -- ) cr ." <DESCRIBE::>" type cr utime ;
: it#{ ( c-addr len -- ) cr ." <IT::>" type cr utime ;
: }# ( -- ) utime cr ." <COMPLETEDIN::>" 2swap d- #ms type ."  ms" cr ;

: failed# ( -- ) cr ." <FAILED::>" ;
: passed# ( -- ) cr ." <PASSED::>" ;

\ data stack
variable ACTUAL-DEPTH
create ACTUAL-RESULTS 32 cells allot
variable START-DEPTH
create EXPECTED-RESULTS 32 cells allot
variable RESULTS
variable DIFFERENCES

\ floating point stack
variable ACTUAL-FDEPTH
create ACTUAL-FRESULTS 32 floats allot
variable START-FDEPTH
create EXPECTED-FRESULTS 32 floats allot
variable FRESULTS
variable FDIFFERENCES

variable #passed

variable ^passed
variable ^nresults
variable ^different
variable ^fnresults
variable ^fdifferent

: passed$  ." Test Passed" cr ;
: different$ ." Expected "
  0 RESULTS @ -do EXPECTED-RESULTS i 1- cells + @ . 1 -loop
  ." , got "
  0 RESULTS @ -do ACTUAL-RESULTS i 1- cells + @ . 1 -loop
  cr ;
: nresults$ ." Wrong number of results, expected " depth START-DEPTH @ - .
  ." , got " ACTUAL-DEPTH @ START-DEPTH @ - dup 0< if negate ." a " . ." cell stack underflow" else . then cr ;
: fdifferent$ ." Expected "
  0 FRESULTS @ -do EXPECTED-FRESULTS i 1- floats + f@ f. 1 -loop
  ." , got "
  0 FRESULTS @ -do ACTUAL-FRESULTS i 1- floats + f@ f. 1 -loop
  cr ;
: fnresults$ ." Wrong number of float results, expected " fdepth START-FDEPTH @ - .
  ." , got " ACTUAL-FDEPTH @ START-FDEPTH @ -
  dup 0< if negate ." a " . ." float stack underflow" else . then cr ;

' passed$ ^passed !
' nresults$ ^nresults !
' different$ ^different !
' fnresults$ ^fnresults !
' fdifferent$ ^fdifferent !

: restore-stack
  depth START-DEPTH @ < if
    depth START-DEPTH @ swap do 0 loop
  then
  depth START-DEPTH @ > if
    depth START-DEPTH @ do drop loop
  then
;

: restore-fstack
  fdepth START-FDEPTH @ < if
    fdepth START-FDEPTH @ swap do 0e loop
  then
  fdepth START-FDEPTH @ > if
    fdepth START-FDEPTH @ do fdrop loop
  then
;

: <{ depth START-DEPTH ! fdepth START-FDEPTH ! ;

: ->
   \ keep actual data stack results
   depth dup ACTUAL-DEPTH !
   START-DEPTH @ >= if
     depth START-DEPTH @ - 0 +do ACTUAL-RESULTS i cells + ! loop
   else \ underflow
     START-DEPTH @ depth - -1 +do 0 loop
   then
   \ keep actual floating point stack results
   fdepth dup ACTUAL-FDEPTH !
   START-FDEPTH @ >= if
     fdepth START-FDEPTH @ - 0 +do ACTUAL-FRESULTS i floats + f! loop
   else \ underflow
     START-FDEPTH @ fdepth - -1 +do 0e loop
   then
;

: }>
  0 #passed !
  \ data stack
  depth ACTUAL-DEPTH @ = if
    depth START-DEPTH @ >= if
      0 DIFFERENCES !
      depth START-DEPTH @ - dup RESULTS ! 0 +do
        dup EXPECTED-RESULTS i cells + !
        ACTUAL-RESULTS i cells + @ <> DIFFERENCES +!
      loop
      DIFFERENCES @ if
        failed# ^different @ execute
      else
        1 #passed +!
      then
    then
  else
    failed# ^nresults @ execute
  then
  restore-stack
  \ floating point stack
  fdepth ACTUAL-FDEPTH @ = if
    fdepth START-FDEPTH @ >= if
      0 FDIFFERENCES !
      fdepth START-FDEPTH @ - dup FRESULTS ! 0 +do
        fdup EXPECTED-FRESULTS i floats + f!
        ACTUAL-FRESULTS i floats + f@ f<> FDIFFERENCES +!
      loop
      FDIFFERENCES @ if
        failed# ^fdifferent @ execute
      else
        1 #passed +!
      then
    then
  else
    failed# ^fnresults @ execute
  then
  restore-fstack
  #passed @ 2 = if passed# ^passed @ execute then
;

3037000493 constant #m \ prime number < sqrt (2^63-1)
53 constant #p         \ prime number
: c# { hash pow c -- hash' pow' } c pow * hash + #m mod pow #p * #m mod ;       \ polynomial rolling hash function, single char
: s# { c-addr len -- hash } 0 1 c-addr len 0 +do { s } s c@ c# s char+ loop 2drop ; \ string hash