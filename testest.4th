\ "Testest" Forth Test Framework for Codewars
\ Copyright 2018-2023 nomennescio
decimal

: #ms ( dmicroseconds -- c-addr len ) <# # # # [char] . hold #s #> ;

: describe#{ ( c-addr len -- ) cr ." <DESCRIBE::>" type cr utime ;
: it#{ ( c-addr len -- ) cr ." <IT::>" type cr utime ;
: }# ( -- ) utime cr ." <COMPLETEDIN::>" 2swap d- #ms type ."  ms" cr ;

' execute alias ^
: @^ ( addr -- ) @ ^ ;
: ++ ( addr -- ) 1 swap +! ;
: 0! ( addr -- ) 0 swap ! ;

: failed# ( -- ) cr ." <FAILED::>" ;
: passed# ( -- ) cr ." <PASSED::>" ;
variable lf lf 0!
: ?lf# ( -- ) lf @ if ." <:LF:>" then lf 0! ;

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
  r* @ dup if ?lf# ." Expected " 0 r* @ -do e* i 1- 's ^ + '@ ^ '. ^ 1 -loop ." , got " 0 r* @ -do a* i 1- 's ^ + '@ ^ '. ^ 1 -loop  cr lf ++ then ;

: different$   #expecteds   expecteds[]   actuals[]   ['] cells  [']  @ [']  . (different$) ;
: different.f$ #expecteds.f expecteds.f[] actuals.f[] ['] floats ['] f@ ['] f. (different$) ;

: (#results$) { #e #a s* s# }
  #e #a - dup if
    ?lf# ." Wrong number of " s* s# type ." results, expected " #e .
    ." , got " #a dup 0< if negate ." a " . s* s# type ." stack underflow" else . then cr lf ++
  then ;

: #results$   #expecteds   @ #actuals   @ s" cell "  (#results$) ;
: #results.f$ #expecteds.f @ #actuals.f @ s" float " (#results$) ;

variable ^passed      ' passed$      ^passed !
variable ^different   ' different$   ^different !
variable ^different.f ' different.f$ ^different.f !
variable ^#results    ' #results$    ^#results !
variable ^#results.f  ' #results.f$  ^#results.f !

: <{ depth start-depth ! fdepth start-fdepth ! lf 0! ;

: store-results { #n s *p '! '0 }
   #n 0 >= if
     *p #n 0 +do { *p } *p '! ^ *p s + loop drop
   else \ underflow
     #n negate -1 +do '0 ^ loop
   then ;

: _0 0 ;
: _0e 0e ;

: store-stacks { #n p* #nf pf* }
 #n  cell  p*  ['] !  ['] _0  store-results \ store cell stack results
 #nf float pf* ['] f! ['] _0e store-results \ store float stack results
;

: ->
 depth  start-depth  @ - dup #actuals   ! actuals[]
 fdepth start-fdepth @ - dup #actuals.f ! actuals.f[]
 store-stacks
;

: compare   { e* a* d -- d' }  e*  @ a*  @  <> d + ;
: compare.f { e* a* d -- d' }  e* f@ a* f@ f<> d + ;

: compare-results { #e #a s e* a* 'cmp }
  #e #a = if
    #e 0 >= if
      0 e* a* #e 0 +do { d e* a* } e* a* d 'cmp ^ e* s + a* s + loop 2drop
      if >r 1+ r> else rot 1+ -rot then
    then
  else 1+ then ;

: }>
  depth  start-depth  @ - dup #expecteds   ! expecteds[]
  fdepth start-fdepth @ - dup #expecteds.f ! expecteds.f[]
  store-stacks
  restore-stack
  restore-fstack
   0 0 0 #expecteds   @ #actuals   @ cell  expecteds[]   actuals[]   ['] compare   compare-results { #p #f #r } \ compare cells
  #p 0 0 #expecteds.f @ #actuals.f @ float expecteds.f[] actuals.f[] ['] compare.f compare-results { #p #ff #rf } \ compare floats
  #r #rf + #f #ff + + if failed#
    #r if ^#results @^ then #rf if ^#results.f @^ then
    #f if ^different @^ then #ff if ^different.f @^ then
  else #p 2 = if passed# ^passed @^ then then ;

3037000493 constant #m \ prime number < sqrt (2^63-1)
53 constant #p         \ prime number
: c# { hash pow c -- hash' pow' } c pow * hash + #m mod pow #p * #m mod ;       \ polynomial rolling hash function, single char
: s# { c-addr len -- hash } 0 1 c-addr len 0 +do { s } s c@ c# s char+ loop 2drop ; \ string hash