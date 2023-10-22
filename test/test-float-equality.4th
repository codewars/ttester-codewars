\ Copyright 2023 nomennescio

\ pass
<{ 1e -> 1e }>
\ fail
<{ 1.001e -> 1e }>

\ abs<> ( f1 f2 -- ? ) := |f1-f2| > epsilon
F<>: abs<>
0.01e epsilon f!
\ pass
<{ 1.001e -> 1e }>
\ fail
<{ 1.1e -> 1e }>
1e epsilon f!
\ pass
<{ 1.1e -> 1e }>

\ rel<> ( f1 f2 -- ? ) := |f1-f2|/|f1+f2| > epsilon
F<>: rel<>
0.05e epsilon f!
\ pass
<{ 5.5e -> 5e }>
<{ 11e -> 10e }>
\ fail
<{ 5.6e -> 5e }>
<{ 11.2e -> 10e }>

\ f<> ( f1 f2 -- ? ) := f1 <> f2
F<>: f<>
\ pass
<{ 1e -> 1e }>
\ fail
<{ 1.001e -> 1e }>
