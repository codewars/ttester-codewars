\ Copyright 2023 nomennescio

\ pass
<{ 1 2e -> 1 2e }>
<{ 1 1e 2 1e f+ -> 1 2 2e }>
<{ 1 2e 2 3e f* -> 1 2 6e }>
<{ 1 0e 2 1e 3 2e -> 1 2 3 0e 1e 2e }>
<{ 1 1e 1e f- 2 0e fcos 3 4e 2e f/ -> 1 2 3 0e 1e 2e }>

\ fail on number of results
<{ 1 2e dup -> 1 2e }>
<{ 1 2e fdup -> 1 2e }>
<{ 1 1e 2 1e f+ dup -> 1 2 2e }>
<{ 1 1e 2 1e f+ fdup -> 1 2 2e }>
<{ 1 2e 2 3e f* dup -> 1 2 6e }>
<{ 1 2e 2 3e f* fdup -> 1 2 6e }>
<{ 1 0e 2 1e 3 2e dup -> 1 2 3 0e 1e 2e }>
<{ 1 0e 2 1e 3 2e fdup -> 1 2 3 0e 1e 2e }>
<{ 1 1e 1e f- 2 0e fcos 3 4e 2e f/ dup -> 1 2 3 0e 1e 2e }>
<{ 1 1e 1e f- 2 0e fcos 3 4e 2e f/ fdup -> 1 2 3 0e 1e 2e }>

<{ 1 2e dup fdup -> 1 2e }>
<{ 1 2e fdup dup -> 1 2e }>
<{ 1 dup 2e fdup -> 1 2e }>

\ fail on differences in outcomes
<{ 1 2e -> 2 2e }>
<{ 1 2e -> 1 1e }>
<{ 1 2e -> 2 1e }>

<{ 1 2 3 4e 5e 6e -> 4 5 6 4e 5e 6e }>
<{ 1 2 3 4e 5e 6e -> 1 2 3 1e 2e 3e }>
<{ 1 2 3 4e 5e 6e -> 4 5 6 1e 2e 3e }>