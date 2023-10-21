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
variable actual-depth
create actual-results 32 cells allot
variable start-depth
create expected-results 32 cells allot
variable results
variable differences

\ floating point stack
variable actual-fdepth
create actual-fresults 32 floats allot
variable start-fdepth
create expected-fresults 32 floats allot
variable fresults
variable fdifferences

variable #passed

variable ^passed
variable ^nresults
variable ^different
variable ^fnresults
variable ^fdifferent

: passed$  ." Test Passed" cr ;
: different$ ." Expected "
  0 results @ -do expected-results i 1- cells + @ . 1 -loop
  ." , got "
  0 results @ -do actual-results i 1- cells + @ . 1 -loop
  cr ;
: nresults$ ." Wrong number of results, expected " depth start-depth @ - .
  ." , got " actual-depth @ start-depth @ - dup 0< if negate ." a " . ." cell stack underflow" else . then cr ;
: fdifferent$ ." Expected "
  0 fresults @ -do expected-fresults i 1- floats + f@ f. 1 -loop
  ." , got "
  0 fresults @ -do actual-fresults i 1- floats + f@ f. 1 -loop
  cr ;
: fnresults$ ." Wrong number of float results, expected " fdepth start-fdepth @ - .
  ." , got " actual-fdepth @ start-fdepth @ -
  dup 0< if negate ." a " . ." float stack underflow" else . then cr ;

' passed$ ^passed !
' nresults$ ^nresults !
' different$ ^different !
' fnresults$ ^fnresults !
' fdifferent$ ^fdifferent !

: restore-stack
  depth { d }
  start-depth @ d +do    0 loop
  d start-depth @ +do drop loop
;

: restore-fstack
  fdepth { fd }
  start-fdepth @ fd +do    0e loop
  fd start-fdepth @ +do fdrop loop
;

: <{ depth start-depth ! fdepth start-fdepth ! ;

: ->
   \ keep actual data stack results
   depth dup actual-depth !
   start-depth @ >= if
     depth start-depth @ - 0 +do actual-results i cells + ! loop
   else \ underflow
     start-depth @ depth - -1 +do 0 loop
   then
   \ keep actual floating point stack results
   fdepth dup actual-fdepth !
   start-fdepth @ >= if
     fdepth start-fdepth @ - 0 +do actual-fresults i floats + f! loop
   else \ underflow
     start-fdepth @ fdepth - -1 +do 0e loop
   then
;

: }>
  0 #passed !
  \ data stack
  depth actual-depth @ = if
    depth start-depth @ >= if
      0 differences !
      depth start-depth @ - dup results ! 0 +do
        dup expected-results i cells + !
        actual-results i cells + @ <> differences +!
      loop
      differences @ if
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
  fdepth actual-fdepth @ = if
    fdepth start-fdepth @ >= if
      0 fdifferences !
      fdepth start-fdepth @ - dup fresults ! 0 +do
        fdup expected-fresults i floats + f!
        actual-fresults i floats + f@ f<> fdifferences +!
      loop
      fdifferences @ if
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