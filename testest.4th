\ "Testest" Forth Test Framework for Codewars
\ Copyright 2018-2023 nomennescio
decimal

: #ms ( dmicroseconds -- c-addr len ) <# # # # [char] . hold #s #> ;

: describe#{ ( c-addr len -- ) cr ." <DESCRIBE::>" type cr utime ;
: it#{ ( c-addr len -- ) cr ." <IT::>" type cr utime ;
: }# ( -- ) utime cr ." <COMPLETEDIN::>" 2swap d- #ms type ."  ms" cr ;

\ address helpers

' execute alias ^
: ?@^ ( ? addr -- ) swap if @ ^ else drop then ;
: ++ ( addr -- ) 1 swap +! ;
: 0! ( addr -- ) 0 swap ! ;
: @+ ( addr -- @ addr++ ) dup @ swap cell+ ;

\ reporting helpers

variable lf
: failed# ( -- ) cr ." <FAILED::>" lf 0! ;
: passed# ( -- ) cr ." <PASSED::>" lf 0! ;
: ?lf# ( -- ) lf @ if ." <:LF:>" then lf 0! ;

\ generic arrays

: [] ( n element-size -- ) create 2dup 0 , , , * allot maxalign ; \ not sure if maxalign is essential
: [0] ( [] -- &a[0] ) 3 cells + ;
: []> ( [] -- n s c &a[0] ) @+ @+ @+ ;
: []. { a[] '@ '. } a[] []> { n s c a* } n c <= if a* n 1- s * + 0 n -do { p* } p* '@ ^ '. ^ p* s - 1 -loop drop then ;

\ data stack            \ floating point stack
variable sp%            variable fp%
32 cell [] actuals[]    32 float [] actuals.f[]
32 cell [] expecteds[]  32 float [] expecteds.f[]

\ stack helpers

: store-stack { a[] '! '0 } a[] []> { n s c a* }
  n 0 >= if n c <= if a* n 0 +do { p* } p* '! ^ p* s + loop drop then else n negate -1 +do '0 ^ loop then ;
: _0 0 ; : _0e 0e ;
: store-stacks { c[] f[] } c[] ['] ! ['] _0 store-stack f[] ['] f! ['] _0e store-stack ;
: mark-stacks ( -- ) sp@ sp% ! fp@ fp% ! ;
: reset-stacks ( -- ... ) sp% @ sp! fp% @ fp! ;

\ support for custom, exact, and inexact floating point comparisons

fvariable epsilon
: rel<> epsilon f@ f~rel 0= ;
: abs<> epsilon f@ f~abs 0= ;
variable ^f<>
: F<>: ' ^f<> ! ;
F<>: f<>

: compare-result  { e* a* d -- d' } e*  @ a*  @   <>     d + ;
: fcompare-result { e* a* d -- d' } e* f@ a* f@ ^f<> @ ^ d + ;
: compare-results { e[] a[] 'cmp } e[] []> a[] []> { #e s ec e* #a _ ac a* } ( #p #f #r -- #p' #f' #r' )
  #e #a = #e 0 >= #e ec <= and and if
    0 e* a* #e 0 +do { d p* q* } p* q* d 'cmp ^ p* s + q* s + loop 2drop
    if >r 1+ r> else rot 1+ -rot then
  else 1+ then ;

\ default reporting

: passed. ." Test Passed" ;
: (different.) { e[] a[] '@ '. } e[] []> a[] [0] { n s c e* a* } n if ?lf# ." Expected " e[] '@ '. []. ." , got " a[] '@ '. []. lf ++ then ;
: different.  expecteds[]   actuals[]   [']  @ [']  . (different.) ;
: fdifferent. expecteds.f[] actuals.f[] ['] f@ ['] f. (different.) ;
: (#results.) { e[] a[] s* s# } e[] []> a[] []> { #e es ec e* #a as ac a* }
  #a ac > if ?lf# ." Too many " s* s# type ."  results to test" lf ++ exit then
  #e ec > if ?lf# ." Too many expected " s* s# type ."  results to test" lf ++ exit then
  #e #a - dup if
    ?lf# ." Wrong number of " s* s# type ."  results, expected " #e .
    ." , got " #a dup 0< if negate ." a " . s* s# type ."  stack underflow" else . then lf ++
  else drop then ;
: #results.  expecteds[]   actuals[]   s" cell "  (#results.) ;
: #fresults. expecteds.f[] actuals.f[] s" float" (#results.) ;

\ custom reporting

variable ^passed.     ' passed.     ^passed.     !
variable ^different.  ' different.  ^different.  !
variable ^fdifferent. ' fdifferent. ^fdifferent. !
variable ^#results.   ' #results.   ^#results.   !
variable ^#fresults.  ' #fresults.  ^#fresults.  !

: #results  sp@ sp% @ swap - cell / ;
: #fresults fp% @ fp@ - float / ;

\ testest unit test

: <{ mark-stacks ;
: -> #results actuals[] tuck ! #fresults actuals.f[] tuck ! store-stacks reset-stacks ;
: }>
  #results expecteds[] tuck ! #fresults expecteds.f[] tuck ! store-stacks reset-stacks
   0 0 0 expecteds[]   actuals[]   [']  compare-result compare-results { #p  #f  #r  } \ compare cells
  #p 0 0 expecteds.f[] actuals.f[] ['] fcompare-result compare-results { #pt #ff #rf } \ compare floats
  #r #rf + #f #ff + + if failed# #r ^#results. ?@^ #rf ^#fresults. ?@^ #f ^different. ?@^ #ff ^fdifferent. ?@^ cr
  else #pt 2 = if passed# ^passed. @ ^ cr then then reset-stacks ;

\ testest utility words

3037000493 constant #m \ prime number < sqrt (2^63-1)
53 constant #p         \ prime number
: c# { hash pow c -- hash' pow' } c pow * hash + #m mod pow #p * #m mod ;       \ polynomial rolling hash function, single char
: s# { c-addr len -- hash } 0 1 c-addr len 0 +do { s } s c@ c# s char+ loop 2drop ; \ string hash
