---
title: ATK16 v2
weight: 0
draft: true
extra:
  kind: project
---

## 2026-03-05 code example with inlining semantics

- inlining probably hard to do in a single pass, would have to maintain some kind of compiler call stack
- `( i n )` are stack assertions, checked at compile time when encountered

```c
: mmio/console/in ( -- addr ) #beef ;  /* push the console input address */

ns: my-program                      /* set namespace to my-program. the % symbol is replaced with this namespace */
: %/count ( -- n )    #f ;          /* define word that pushes the loop count */

: % ( -- )                          /* define main program */
    %/count loop{                   /* countdown from count..0, writing each value to console */
        ifn'{ drop break }          /* jump to } if stack top is nonzero */
                                    /* note: ifn'{ is the nonconsuming variant of ifn{ */

                                    ( i n )
        ~mmio/console/in swap       ( i addr n )
                                    /* note: ~ inlines the callee body instead of emitting a jump */

        !                           /* write to the console port */

        1 -                         ( i-1 )
    } ;

my-program     /* run the program */
```

- compile & run idea: one enter press runs compile, second in a row runs from last stop point
  - how exactly does control return to the editor/REPL?
- better idea: normal keypresses just go into a preallocated text area, and a CTRL+R (etc) run command starts parsing and running it
  - note that nothing will jump back automatically, so emit a control stack pop and jump to return to the REPL
  - read: get characters until whitespace or EOF
  - execute: get matching word from dictionary and jump to it, error if not found
  - print: some status information, dict size etc.
  - loop
- the compiler word (:) will consume more words from the input area

## code example with immediate execution semantics, no inlining

```c
: mmio/console/in ( -- addr ) #beef ;  /* push the console input address */

ns: my-program                      /* set namespace to my-program. the % symbol is replaced with this namespace */
: %/count ( -- n )    #f ;          /* define word that pushes the loop count */

: % ( -- )                          /* define main program */
    %/count loop{                   /* countdown from count..0, writing each value to console */
        ifn'{ drop break }          /* jump to } if stack top is nonzero */
                                    /* note: ifn'{ is the nonconsuming variant of ifn{ */

                                    ( i )
        ~{ mmio/console/in # }      /* inside ~{ } is immediate mode, which makes all words act like immediate/compiler words */
                                    /* # takes a word X from the compiler data stack and emits a LIT X instruction that pushes X */
        over                        ( i addr n )

        !                           /* write to the console port */

        1 -                         ( i-1 )
    } ;

my-program     /* run the program */
```

- This makes me think that a simple interpreter is probably necessary as part of the REPL
- It doesn't have to support everything, maybe only word calls e.g. `my-program` and `:`, and maybe literals too e.g. `#abcd`
  - The interpreter should NOT run compiler words

The core REPL loop should then look like this:

- Read next word
- If it starts with a `#`, push value to stack, continue loop.
- Find a matching word. If it exists and is not a compiler word, call it, continue loop.
- Print error, continue loop.

The core `:` loop should look like this:

- Enable "compiler mode flag"
- Parse name
- Parse stack effect declaration, store in metadata field
- Read next word
- If the word starts with a sigil (not a-zA-Z0-9 basically, but with öäå), move parser pointer to second character, set WORD to `:/sigil/<symbol>`
  - The sigil handlers mostly expand to a reader word, i.e. a word that consume from the input stream
  - E.g. `#1000` -> `[ LIT 1000 ]`
- Else, set WORD to the whole parsed word.
- If WORD is a compiler word && immediate mode is on, print error, exit `:`.
- If WORD is a compiler word || immediate mode is on, call it, continue.
- Lookup the word as is and emit a call to it, continue.
- Try interpreting the word as an hex value and emit it as is, continue.
- Print error, exit `:`.

Global variables

```c
:/mode          /* 1 if compiling, 0 if interpreting */
:/cword/offset  /* current word to compile, offset into input stream */
:/cword/length

etc todo
```

- Still a bit unsure how the `ns:` and `%` syntax should look like.
  - It currently feels like it would require a bunch of special processing in the `:` compiler to be supported

```c
: const ( -- a )
    ~{ R/next R/interpret # } ; immediate

: constants/abc     #beef ;
: my-program ( -- )
    [ const constants/abc ]     ( abc )     /* [ and ] are just for formatting, no effect */
    #0010 +                     ( n )
    drop
;
```

- How should the stack analysis handle immediate mode execution? Just blindly trust the declared stack effect?
- We can't really disable stack effect checking except on a whole-word basis
  - Maybe require that each immediate block is followed by a stack assertion to get the checker back on track?
    - Could be hard to use
- Maybe just remove the `~{` and `}` immediate mode altogether and require a "wrapper compiler word" for metaprogramming
  - Then we could just trust the stack effect of the compiler/immediate word
  - Would be very simple:

```c
: count ( -- a ) #f     # ; immediate
: program ( -- )
    count           ( n )
    drop            ( )
    ;
```

- Yeah, I think the above is good
- Now I'm wondering about conditionals. If we just have `if{` and `}` (and possibly a `ifz{` variant), we must require that the fallthrough delta == the "branch taken" delta, which means that "branch taken" delta must be always be zero. This is very inconvenient. Maybe we could group conditionals something like this:

```c
#0 cond{
   ?{      /* if zero */         }
   10 - ?{ /* if 16 (decimal) */ }
}
```

- The semantics of the above idea:
  - `cond{` starts a conditional context
    - `}` ends it, patch all "jump to end" slots
  - `?{` emit "jump if zero", add its slot to patch list
    - `}` patch jump, emit "jump to end", add its slot to patch list
  - stack effect checker ensures that join point after cond block is consistent

```c
#0
    dup     ?{ /* if zero */    },
    dup 1 - ?{ /* if one */     },
    dup 2 - ?{ /* if two */     },
         else{ /* otherwise */  }
```

- Semantics of above:
  - `?{` start branch, emit JNZ to next closing brace (`}`, or `},`), add slot to patch list
  - `},` emit a JMP to join point (`}`), add its slot to patch list, close branch, patch JNZ
  - `}` close branch, patch JNZ and JMPs
- "else" can be simulated with a `drop #0 ?{`
  - or maybe just a `else{` that is a NOP that adds a dummy patch list entry for `}` to work properly
- should work with the stack checker without any tricks

- We probably have to keep track of the number of patch slots since the `}` must patch multiple slots, and it cannot patch all of them because then it might patch those from an outer context (a loop etc.). Maybe in the loop context object?

```c
/* Control context struct */
[ 16 context type ][ 16 patch slots in ctx ]

: ctrl/type/word  ( -- a )     #0 ; immediate
: ctrl/type/?{    ( -- a )     #1 ; immediate
: ctrl/type/loop{ ( -- a )     #2 ; immediate

: }/word ( ps-count ctx-type -- )
    /* todo */
    ; immediate

: } ( -- )
    C> C>                      ( ps-count ctx-type )
    dup ctrl/type/word -       ( ps-count ctx-type pred? )
        [ callz }/word ]
    dup ctrl/type/?{ -         ( ps-count ctx-type pred? )
        [ callz }/{? ]
    ; immediate
```

- Idea above: the control structures `?{ ... }` and `loop{ break next ... }` cannot be defined in terms of themselves
  - => Need to use `callz` (call if zero) and `calln` (call if nonzero).

- Radical idea: only one stack (no control stack):

```c
: foo ( a b r -- a+b r )
    rot2        ( r a b )
    +           ( r a+b )
    swap
    ;


: program ( -- n )
    1 2 foo ;
```

- Yea uhh very unwieldy

- Idea about notation for both data and return stacks:

```c
: foo ( a -- n :: r -- )
    c>d         ( a b :: )
    +           ( a+b )
    ;
```

- Syntax for the stack effect declaration

```c
/* no declaration */   => error, data stack effect required
( )                    => error, missing -- in data stack
( -- )                 => data: 0 in, 0 out; return: 0 in, 0 out
( a b -- c )           => data: 2 in, 1 out; return: 0 in, 0 out
( a b -- c :: )        => error, missing -- in return stack
( a b -- c :: r -- g ) => data: 2 in, 1 out; return: 1 in, 1 out
```

- Syntax for the stack assertion:

```c
/* no declaration */   => no assertion done
( )                    => data: 0, return: 0
( a b )                => data: 2, return: 0
( a b :: )             => data: 2, return: 0
( a b :: c )           => data: 2, return: 1
( a b -- :: c )        => error, -- forbidden in assertion
```

- A dictionary entry format:

```c
[ 16 link ]                 /* pointer to start of previous entry, or null */
[ 16 namelen ]              /* length of name, in words */
[ 16*namelen name ]         /* name character data */
[ 8 ninputs ][ 8 delta ]    /* number of inputs on stack, (signed) delta = noutputs - ninputs */
[ 16 meta ]                 /* flags etc */
[ 16 doc ]                  /* docstring pointer, or null */
[ 16 deflen ]               /* length of definition, in words */
[ 16*deflen def ]           /* definition words */
```

- `meta` being a bitfield with bits:

```
[0]     compiler word
[1]     program (not data)
[2..15] unused
```

- Instruction set concepting
  - Instructions with apostrophe are non-consuming variants
  - E.g. `slip` has `( a b -- b a )`, but `slip'` has `( a b -- b a b )`
  - The jump immediate variants are useful for patching, but they could theoretically be implemented as a `lit <imm>` + `jmp`/`jz`
  - Instead of implementing jump variants for different ALU flags, maybe allow loading the ALU flags as a bitfield onto the stack (`lfg`)?
    - Probably not necessary, you can compute overflow/carry/negative using jz and the available ALU ops
  - The `slip` (top to second), `bury` (top to third), `pick` (second to top) and `dig` (third to top) are named like that for easier remembering
    - I never remember which way `over` or `rot` work in Forth
  - The instructions spanning two columns in the table are long format, i.e. two words or 32 bits in total.

```toml
stack manipulation    alu                control            memory
[ lit     <imm>   ]   [ add ] [ add' ]   [ jma  ] [ jma' ]   [ load  ] [ load'  ]
[ dup  ]  [ nip   ]   [ sub ] [ sub' ]   [ jza  ] [ jza' ]   [ store ] [ store' ]
[ drop ]              [ and ] [ and' ]   [ jmr  ] [ jmr' ]
[ slip ]  [ slip' ]   [ or  ] [ or'  ]   [ jzr  ] [ jzr' ]
[ bury ]  [ bury' ]   [ xor ] [ xor' ]
[ pick ]  [ pick' ]   [ shl ] [ shl' ]   [ lpc   ]
[ dig  ]  [ dig'  ]   [ shr ] [ shr' ]   [ nop   ]
[ c>d  ]  [ c>d'  ]   [ sar ] [ sar' ]   [ hlt   ]
[ d>c  ]  [ d>c'  ]
```

- for good call ergonomics I think `lpc` should get `PC+2` and push it onto the return stack
  - call would then be `lpc jmp`
  - ret would be `c>d jmp`
- since `lpc` and `jmp` operate on different stacks, we could have one-cycle `call` and `ret` instruction
  - probably overengineering, it's fine to have two-cycle function prologue and epilogue

- Simple if-else approach instead of the multi branch solution before

```c
#0
    if{ true branch }
    else{ false branch }
```

- Nah probably not. Let's go with the `?{ ... }` syntax designed above.
- Thinking about inlining: to inline a `:` definition, the compiler would have to loop over the the compiled body of the definition and emit each word to HERE. This requires a `deflen` to exist. A problem arises with jumps: a word-internal, absolute jump would become invalid if the definition is moved. A relative jump would work still. Jumps to other `:` words would have to absolute, though.
  - This could be solvable by compiling all control structures (conditional branches and loops) to relative jumps (need to add these to the ISA), and calls to absolute jumps.

- Idea about a stack checker that only has assertions:
  - The big issue is that the "return type" is now after the body

```c
: foo ( a b c )
  + + ( a+b+c )
  ;
```

```c
: foo ( a b c :: r )              /* data: 3, control: 1 */
    + +         ( result :: r )   /* data: 1, control: 1 */
    c>d         ( result r :: )   /* data: 2, control: 0 */
    d>c         ( result :: r )   /* data: 1, control: 1 */
    ;
```

- Conclusion! If we forbid:
  - word-internal absolute addressing jumps, and
  - word-external relative addressing jumps,
- and require that words can only directly call already defined words (not self, forbidding recursion),
- all words become location-independent and can be inlined freely by the compiler via simple `memcpy`
- it is always beneficial (smaller current word length + fewer total executed instrs) to inline words with deflen<=2
  - because call overhead is 2 in the caller (prologue)
- it is mostly beneficial (fewer total executed instrs) to inline words with deflen<=4
  - because call overhead is 2 in the callee too (epilogue)
- longer words should be inlined based on some heuristics, e.g. callee max deflen <=8 and caller max deflen <=32 or something like that.
  - probably could use profiling to find optimum

- Recursion can be reconstructed by continuation passing from an other word: call word `inner` and pass `&inner` as an argument
  - Actually direct self-recursion is also fine if we just use absolute addressing
  - This would actually avoid the issue of inlining one copy of a recursive implementation to the outer function that still jumps to the inner one, wasting space

- Another thing: if a word definition ends in a word call, we can do a tail call optimization.
  - A normal word call at tail position: `[ lpc jma ] [ c>d jma ]`
  - Optimized word call at tail position: `jma`
- I.e. we don't have to return back to the caller just to immediately jump to its caller. We can skip the tail call site altogether.
  - This works through any number of call stack layers

- Thinking about loops: [Moore says](https://www.ultratechnology.com/moore4th.htm) that they prefer to use manual repetition or recursion instead of looping constructs
- Maybe we could also manage with just a conditional and recursion?

```c
: con/out   #beef ;
: loop ( count )
    dup con/out     ( count count addr )
    !
    #1 -            ( count-1 )
    ?loop           /* if non-zero, recurse. this marks `loop` as `noinline` */
    ;
: program ( )
    #f loop ;
```

- Here, `?` is a sigil that jumps to the word following it using absolute addressing if stack top is non-zero.
  - `?<word>` consumes its argument, making it a good fit for tail position calls
  - The current word's header is already written to the dictionary at this point so no special handling needed for self recursion
- Consider marking a word `noinline` if it refers to itself by name or uses `here` (which emits a literal instruction with the current compiler head address)
  - A mistakenly inlined "non-inlinable" word would still work I guess, but it would be not very elegant
    - I.e. the first iteration would be executed from the caller memory, but when the recursive jump is encountered, it jumps to the callee memory. They have the same instructions in both memory areas so it should work, but eh.

- Let's try to imagine an "early return" scenario with fibonacci and see how this model works:

```c
: return ( :: r )
    c>d jma ;   /* If inlined, this should work like an early return */

: fibo ( n )
    dup      ?return    ( n )
    dup #1 - ?return    ( n )
    #1 - dup            ( n-1 n-1 )
    fibo swap           ( fibo_n-1 n-1 )
    #1 - fibo           ( fibo_n-1 fibo_n-2 )
    +                   ( fibo_n )
    ;
```

- This has multiple problems:
  - How to notate the return value of the early return? The `return` word itself is not "polymorphic" in data stack height
  - There are now multiple exit points, how to ensure that they all have the same stack height?
- This makes me think that early return, at least implemented like this, is not the approach

```c
: fibo0 ( n :: r _ )
    c>d drop c>d over        ( n r n )
    jz ( n ) ;
: fibo1 ( n :: r )
    #1 -                ( n-1 )
    c>d drop c>d over   ( n-1 r n-1 )
    jz ( n-1 ) ;
: fibo ( n )
    fibo0           ( n>0 )
    fibo1           ( n>1 )
    dup #1 -        ( n n-1 )
    over #2 -       ( n-1 n-2 )
    + fibo          ( n )
```

- This could work, but it kind of circumvents the whole control stack thing by manually jumping to the caller's return address manually to implement early return
  - I'm sure there's a better design

- Maybe if the caller provides a "continuation":

```c
: fibo/0 ( k n )
    dup rot ( n k n ) jz ;
: fibo/1 ( k n )
    #1 -
    dup rot ( n-1 k n-1 ) jz ;
: fibo ( n :: k )
    dup c>d dup     ( n n k k )
    rot swap        ( n k k n )
    fibo/0          ( n k )
    over            ( n k n )
    fibo/1          ( n )
    dup #1 - fibo   ( n fibon-1 )
    swap #2 - fibo  ( fibon-1 fibon-2 )
    +               ( fibon )
    ;
```

- Pretty inconvenient still with all the shuffling on the data stack and the `jz`
- Maybe if we push the continuation manually on the return stack?
  - No, that isn't possible since the helper words still need to be able to return to the main word in case the condition does not hold
- Maybe if we have a specific "early return" keyword `ret` that jumps to `k` on CS
  - And a conditional variant `?ret` obviously that jumps if `n` on DS is zero

```c
: ?ret ( pred :: k )
    c>d' swap jz ( :: k ) ;

: fibo ( n :: k )
    dup                 ( n n :: k )
    ?ret                ( n :: k ) /* return to k if tos == 0 */
    dup #1 -            ( n n-1 :: k )
    ?ret                ( n :: k ) /* return k to if tos == 1 */
    #1 - dup #1 -       ( n-1 n-2 :: k )
    fibo swap fibo +    ( fibo_n )
    ;
```

- This is actually pretty good, but there's still bit of work with the control stack
  - Now `?ret` would jump to the continuation where `k` would still be unconsumed on the CS
- How about trying to do a switch-case kind of jump table?

```c
/* map 1 => 10, 2 => 20, 3 => 30 */
: map ( n :: k )
    dup #10 swap #1 -        ( n 10 n-1 :: k )
    ?ret                     ( n 10 :: k )
    ...
```

- Hmm I don't know

- Maybe a very explicit when-case-then-endwhen construct?
  - This would be super simple to compile if we disallow nesting, but nesting could be done without issue

```c
/* map 1 => 10, 2 => 20, 3 => 30 */
: map ( n )
    when case dup #1 = then #10
         case dup #2 = then #20
         case dup #3 = then #30
         else               #40
    endwhen drop ( m ) ;
```

- The idea is that we keep track of two numbers: a predicate delta and a branch delta. First they are undefined and the first case-then compound sets them. The deltas of the later cases must match the first ones, or otherwise error.

Above `map` example hand-compiled:

```c
/* map ( n ) */
    case0: dup [ lit 1 ] = [ jz :case1 ] [ lit 10 ] [ jmp :endwhen ]
    case1: dup [ lit 2 ] = [ jz :case2 ] [ lit 20 ] [ jmp :endwhen ]
    case2: dup [ lit 3 ] = [ jz :case3 ] [ lit 30 ] [ jmp :endwhen ]
    case3: [ lit 30 ] [ jmp :endwhen ]
    endwhen:
```
