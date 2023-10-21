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
variable expected-depth
create expected-results 32 cells allot
variable results
variable differences

\ floating point stack
variable actual-fdepth
create actual-fresults 32 floats allot
variable start-fdepth
variable expected-fdepth
create expected-fresults 32 floats allot
variable fresults
variable fdifferences

variable #passed
variable #failed
variable #results

variable ^passed
variable ^nresults
variable ^different
variable ^fnresults
variable ^fdifferent

: passed$  ." Test Passed" cr ;

: different$
  results @ if
  ." Expected "
  0 results @ -do expected-results i 1- cells + @ . 1 -loop
  ." , got "
  0 results @ -do actual-results i 1- cells + @ . 1 -loop
  cr
  then ;

: nresults$
  expected-depth @ actual-depth @ - if
  ." Wrong number of results, expected " expected-depth @ start-depth @ - .
  ." , got " actual-depth @ start-depth @ - dup 0< if negate ." a " . ." cell stack underflow" else . then cr
  then ;

: fdifferent$
  fresults @ if
  ." Expected "
  0 fresults @ -do expected-fresults i 1- floats + f@ f. 1 -loop
  ." , got "
  0 fresults @ -do actual-fresults i 1- floats + f@ f. 1 -loop
  cr
  then ;

: fnresults$
  expected-fdepth @ actual-fdepth @ - if
  ." Wrong number of float results, expected " expected-fdepth @ start-fdepth @ - .
  ." , got " actual-fdepth @ start-fdepth @ - dup 0< if negate ." a " . ." float stack underflow" else . then cr
  then ;

' passed$ ^passed !
' nresults$ ^nresults !
' different$ ^different !
' fnresults$ ^fnresults !
' fdifferent$ ^fdifferent !

: restore-stack { d -- ... } start-depth @ d - sp@ + sp! ;
: restore-fstack { fd -- ... } start-fdepth @ fd - fp@ + fp! ;

: <{ depth start-depth ! fdepth start-fdepth ! ;

: ->
   \ store actual data stack results
   depth start-depth @ { d s } d actual-depth !
   d s >= if
     d s - 0 +do actual-results i cells + ! loop
   else \ underflow
     s d - -1 +do 0 loop
   then
   \ store actual floating point stack results
   fdepth start-fdepth @ { d s } d actual-fdepth !
   d s >= if
     d s - 0 +do actual-fresults i floats + f! loop
   else \ underflow
     s d - -1 +do 0e loop
   then
;

: }>
  depth actual-depth @ start-depth @ { d a s } d expected-depth !
  0 #passed ! 0 #failed ! 0 #results !
  \ data stack
  d a = if
    d s >= if
      0 differences !
      d s - dup results ! 0 +do
        dup expected-results i cells + !
        actual-results i cells + @ <> differences +!
      loop
      differences @ if
        1 #failed +!
      else
        1 #passed +!
      then
    then
  else
    1 #results +!
  then
  depth restore-stack
  \ floating point stack
  fdepth actual-fdepth @ start-fdepth @ { d a s } d expected-fdepth !
  d a = if
    d s >= if
      0 fdifferences !
      fdepth s - dup fresults ! 0 +do
        fdup expected-fresults i floats + f!
        actual-fresults i floats + f@ f<> fdifferences +!
      loop
      fdifferences @ if
        1 #failed +!
      else
        1 #passed +!
      then
    then
  else
    1 #results +!
  then
  fdepth restore-fstack
  \ pass test results to framework
  #results @ #failed @ + if
    failed#
    #results @ if
      ^nresults @ execute
      ^fnresults @ execute
      then
    #failed @ if ^different @ execute ^fdifferent @ execute then
  then
  #passed @ 2 = if passed# ^passed @ execute then
;

3037000493 constant #m \ prime number < sqrt (2^63-1)
53 constant #p         \ prime number
: c# { hash pow c -- hash' pow' } c pow * hash + #m mod pow #p * #m mod ;       \ polynomial rolling hash function, single char
: s# { c-addr len -- hash } 0 1 c-addr len 0 +do { s } s c@ c# s char+ loop 2drop ; \ string hash