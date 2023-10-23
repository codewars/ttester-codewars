\ "Testest" Forth Test Framework for Codewars
\ Copyright 2018-2023 nomennescio
decimal

: #ms ( dmicroseconds -- c-addr len ) <# # # # [char] . hold #s #> ;

: describe#{ ( c-addr len -- ) cr ." <DESCRIBE::>" type cr utime ;
: it#{ ( c-addr len -- ) cr ." <IT::>" type cr utime ;
: }# ( -- ) utime cr ." <COMPLETEDIN::>" 2swap d- #ms type ."  ms" cr ;

' execute alias ^
: ?@^ ( ? addr -- ) swap if @ ^ else drop then ;
: ++ ( addr -- ) 1 swap +! ;
: 0! ( addr -- ) 0 swap ! ;

: failed# ( -- ) cr ." <FAILED::>" ;
: passed# ( -- ) cr ." <PASSED::>" ;
variable lf lf 0!
: ?lf# ( -- ) lf @ if ." <:LF:>" then lf 0! ;

: [] ( n element-size -- ) create 2dup 0 , , , * allot maxalign ; \ not sure if maxalign is essential
: [0] ( [] -- &a[0] ) 3 cells + ;
: []> ( [] -- n s &a[0] ) >r r@ @ r@ cell+ @ r> [0] ;

\ data stack
variable start-depth
32 cell [] actuals[]
32 cell [] expecteds[]

\ floating point stack
variable start-fdepth
32 float [] actuals.f[]
32 float [] expecteds.f[]

: restore-stack ( -- ... ) depth {  d }  start-depth @  d +do  0 loop  d  start-depth @ +do  drop loop ;
: restore-fstack ( -- )   fdepth { fd } start-fdepth @ fd +do 0e loop fd start-fdepth @ +do fdrop loop ;

: passed$ ." Test Passed" cr ;

: (different$) { e[] a[] 's '@ '. } e[] dup @ swap [0] a[] [0] { n e* a* }
  n dup if ?lf# ." Expected " 0 n -do e* i 1- 's ^ + '@ ^ '. ^ 1 -loop ." , got " 0 n -do a* i 1- 's ^ + '@ ^ '. ^ 1 -loop  cr lf ++ then ;

: different$   expecteds[]   actuals[]   ['] cells  [']  @ [']  . (different$) ;
: different.f$ expecteds.f[] actuals.f[] ['] floats ['] f@ ['] f. (different$) ;

: (#results$) { #e #a s* s# }
  #e #a - dup if
    ?lf# ." Wrong number of " s* s# type ." results, expected " #e .
    ." , got " #a dup 0< if negate ." a " . s* s# type ." stack underflow" else . then cr lf ++
  then ;

: #results$   expecteds[]   @ actuals[]   @ s" cell "  (#results$) ;
: #results.f$ expecteds.f[] @ actuals.f[] @ s" float " (#results$) ;

variable ^passed$      ' passed$      ^passed$ !
variable ^different$   ' different$   ^different$ !
variable ^different.f$ ' different.f$ ^different.f$ !
variable ^#results$    ' #results$    ^#results$ !
variable ^#results.f$  ' #results.f$  ^#results.f$ !

: <{ depth start-depth ! fdepth start-fdepth ! lf 0! ;

: store-results { n *p s '! '0 }
   n 0 >= if
     *p n 0 +do { *p } *p '! ^ *p s + loop drop
   else \ underflow
     n negate -1 +do '0 ^ loop
   then ;

: _0 0 ;
: _0e 0e ;

: store-stacks { #c c* #f f* } #c c* cell ['] ! ['] _0 store-results #f f* float ['] f! ['] _0e store-results ;

: -> depth start-depth @ - dup actuals[] ! actuals[] [0] fdepth start-fdepth @ - dup actuals.f[] ! actuals.f[] [0] store-stacks ;

variable ^f<>
: F<>: ' ^f<> ! ;
F<>: f<>

fvariable epsilon
: rel<> epsilon f@ f~rel 0= ;
: abs<> epsilon f@ f~abs 0= ;

: compare   { e* a* d -- d' }  e*  @ a*  @  <> d + ;
: compare.f { e* a* d -- d' }  e* f@ a* f@ ^f<> @ ^ d + ;

: compare-results { e[] a[] 'cmp } e[] []> a[] []> { #e s e* #a _ a* } ( #p #f #r -- #p' #f' #r' )
  #e #a = if
    #e 0 >= if
      0 e* a* #e 0 +do { d e* a* } e* a* d 'cmp ^ e* s + a* s + loop 2drop
      if >r 1+ r> else rot 1+ -rot then
    then
  else 1+ then ;

: }>
  depth start-depth @ - dup expecteds[] ! expecteds[] [0] fdepth start-fdepth @ - dup expecteds.f[] ! expecteds.f[] [0] store-stacks
  restore-stack restore-fstack
   0 0 0 expecteds[] actuals[] ['] compare   compare-results { #p #f #r } \ compare cells
  #p 0 0 expecteds.f[] actuals.f[] ['] compare.f compare-results { #p #ff #rf } \ compare floats
  #r #rf + #f #ff + + if failed# #r ^#results$ ?@^ #rf ^#results.f$ ?@^ #f ^different$ ?@^ #ff ^different.f$ ?@^
  else #p 2 = if passed# ^passed$ @ ^ then then ;

3037000493 constant #m \ prime number < sqrt (2^63-1)
53 constant #p         \ prime number
: c# { hash pow c -- hash' pow' } c pow * hash + #m mod pow #p * #m mod ;       \ polynomial rolling hash function, single char
: s# { c-addr len -- hash } 0 1 c-addr len 0 +do { s } s c@ c# s char+ loop 2drop ; \ string hash