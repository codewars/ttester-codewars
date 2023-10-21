\ ttester extension for Codewars
\ Copyright 2019-2023 nomennescio
decimal

: #ms ( dmicroseconds -- c-addr len ) <# # # # [char] . hold #s #> ;

: describe#{ ( c-addr len -- ) cr ." <DESCRIBE::>" type cr utime ;
: it#{ ( c-addr len -- ) cr ." <IT::>" type cr utime ;
: }# ( -- ) utime cr ." <COMPLETEDIN::>" 2swap d- #ms type ."  ms" cr ;

: failed# ( -- ) cr ." <FAILED::>" ;
: passed# ( -- ) cr ." <PASSED::>" ;

' execute alias ^
: @^ ( addr -- ) @ ^ ;
: ++ ( addr -- ) 1 swap +! ;
: 0! ( addr -- ) 0 swap ! ;

\ data stack
variable #actuals
create actual-results 32 cells allot
variable start-depth
variable #expecteds
create expected-results 32 cells allot
variable results
variable differences

\ floating point stack
variable #actuals.f
create actual-fresults 32 floats allot
variable start-fdepth
variable #expecteds.f
create expected-fresults 32 floats allot
variable fresults
variable fdifferences

: restore-stack ( -- ... ) depth start-depth @ swap - sp@ + sp! ;
: restore-fstack ( -- ) start-fdepth @ fdepth - fp@ + fp! ;

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

: fdifferent$
  fresults @ if
  ." Expected "
  0 fresults @ -do expected-fresults i 1- floats + f@ f. 1 -loop
  ." , got "
  0 fresults @ -do actual-fresults i 1- floats + f@ f. 1 -loop
  cr
  then ;

: nresults$
  #expecteds @ #actuals @ - if
  ." Wrong number of results, expected " #expecteds @ .
  ." , got " #actuals @ dup 0< if negate ." a " . ." cell stack underflow" else . then cr
  then ;

: fnresults$
  #expecteds.f @ #actuals.f @ - if
  ." Wrong number of float results, expected " #expecteds.f @ .
  ." , got " #actuals.f @ dup 0< if negate ." a " . ." float stack underflow" else . then cr
  then ;

' passed$ ^passed !
' nresults$ ^nresults !
' different$ ^different !
' fnresults$ ^fnresults !
' fdifferent$ ^fdifferent !

: <{ depth start-depth ! fdepth start-fdepth ! ;

: store-results { #a s *r '! '0 }
   #a 0 >= if
     *r #a 0 +do { *r } *r '! ^ *r s + loop drop
   else \ underflow
     #a negate -1 +do '0 ^ loop
   then
;

: _0 0 ;
: _0e 0e ;

: ->
   \ store actual data stack results
   depth start-depth @ - dup #actuals ! cell actual-results ['] ! ['] _0 store-results
   \ store actual floating point stack results
   fdepth start-fdepth @ - dup #actuals.f ! float actual-fresults ['] f! ['] _0e store-results
;

: compare   { e* a* d* }  dup e*  ! a*  @  <> d* +! ;
: compare.f { e* a* d* } fdup e* f! a* f@ f<> d* +! ;

: compare-results { #e #a s e* a* r* d* 'cmp }
  #e #a = if
    #e 0 >= if 0 d* !
      e* a* #e dup r* ! 0 +do { e* a* } e* a* d* 'cmp ^ e* s + a* s + loop 2drop
      1 d* @ if #failed else #passed then +!
    then
  else 1 #results +! then
;

: }>
  0 #passed ! 0 #failed ! 0 #results !
  \ data stack
  depth start-depth @ - dup #expecteds ! #actuals @ cell expected-results actual-results results differences ['] compare compare-results
  restore-stack
  \ floating point stack
  fdepth start-fdepth @ - dup  #expecteds.f ! #actuals.f @ float expected-fresults actual-fresults fresults fdifferences ['] compare.f compare-results
  restore-fstack
  \ pass test results to framework
  #results @ #failed @ + if failed#
    #results @ if ^nresults @^ ^fnresults @^ else #failed @ if ^different @^ ^fdifferent @^ then then
  else #passed @ 2 = if passed# ^passed @^ then then
;

3037000493 constant #m \ prime number < sqrt (2^63-1)
53 constant #p         \ prime number
: c# { hash pow c -- hash' pow' } c pow * hash + #m mod pow #p * #m mod ;       \ polynomial rolling hash function, single char
: s# { c-addr len -- hash } 0 1 c-addr len 0 +do { s } s c@ c# s char+ loop 2drop ; \ string hash