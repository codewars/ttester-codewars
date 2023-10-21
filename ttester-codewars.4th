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
variable start-depth
variable #actuals   create actuals[]   32 cells allot
variable #expecteds create expecteds[] 32 cells allot

\ floating point stack
variable start-fdepth
variable #actuals.f   create actuals.f[]   32 floats allot
variable #expecteds.f create expecteds.f[] 32 floats allot

: restore-stack ( -- ... ) depth {  d }  start-depth @  d +do  0 loop  d  start-depth @ +do  drop loop ;
: restore-fstack ( -- )   fdepth { fd } start-fdepth @ fd +do 0e loop fd start-fdepth @ +do fdrop loop ;

: passed$  ." Test Passed" cr ;

: (different$) { r* e* a* 's '@ '. }
  r* @ if ." Expected " 0 r* @ -do e* i 1- 's ^ + '@ ^ '. ^ 1 -loop ." , got " 0 r* @ -do a* i 1- 's ^ + '@ ^ '. ^ 1 -loop  cr then ;

:  different$ #expecteds   expecteds[]   actuals[]   ['] cells  [']  @ [']  . (different$) ;
: fdifferent$ #expecteds.f expecteds.f[] actuals.f[] ['] floats ['] f@ ['] f. (different$) ;

: (nresults$) { #e #a s* s# }
  #e #a - if
    ." Wrong number of " s* s# type ." results, expected " #e .
    ." , got " #a dup 0< if negate ." a " . s* s# type ." stack underflow" else . then cr
  then ;

:  nresults$ #expecteds   @ #actuals   @ s" cell "  (nresults$) ;
: fnresults$ #expecteds.f @ #actuals.f @ s" float " (nresults$) ;

variable ^passed     ' passed$     ^passed !
variable ^different  ' different$  ^different !
variable ^fdifferent ' fdifferent$ ^fdifferent !
variable ^nresults   ' nresults$   ^nresults !
variable ^fnresults  ' fnresults$  ^fnresults !

: <{ depth start-depth ! fdepth start-fdepth ! ;

: store-results { #a s *r '! '0 }
   #a 0 >= if
     *r #a 0 +do { *r } *r '! ^ *r s + loop drop
   else \ underflow
     #a negate -1 +do '0 ^ loop
   then ;

: _0 0 ;
: _0e 0e ;

: ->
 depth  start-depth  @ - dup #actuals   ! cell  actuals[]   ['] !  ['] _0  store-results \ store cell stack results
 fdepth start-fdepth @ - dup #actuals.f ! float actuals.f[] ['] f! ['] _0e store-results \ store float stack results
;

variable #passed variable #failed variable #results

: compare   { e* a* d -- d' }  dup e*  ! a*  @  <> d + ;
: compare.f { e* a* d -- d' } fdup e* f! a* f@ f<> d + ;

: compare-results { #e #a s e* a* 'cmp }
  #e #a = if
    #e 0 >= if
      0 e* a* #e 0 +do { d e* a* } e* a* d 'cmp ^ e* s + a* s + loop 2drop
      if #failed else #passed then ++
    then
  else #results ++ then ;

: }>
  #passed 0! #failed 0! #results 0! \ user code has already finished running here
  depth start-depth @ - dup #expecteds ! #actuals @ cell expecteds[] actuals[] ['] compare compare-results \ compare cell stack
  restore-stack
  fdepth start-fdepth @ - dup  #expecteds.f ! #actuals.f @ float expecteds.f[] actuals.f[] ['] compare.f compare-results \ compare float stack
  restore-fstack
  \ pass test results to framework
  #results @ #failed @ + if failed#
    #results @ if ^nresults @^ ^fnresults @^ else #failed @ if ^different @^ ^fdifferent @^ then then
  else #passed @ 2 = if passed# ^passed @^ then then ;

3037000493 constant #m \ prime number < sqrt (2^63-1)
53 constant #p         \ prime number
: c# { hash pow c -- hash' pow' } c pow * hash + #m mod pow #p * #m mod ;       \ polynomial rolling hash function, single char
: s# { c-addr len -- hash } 0 1 c-addr len 0 +do { s } s c@ c# s char+ loop 2drop ; \ string hash