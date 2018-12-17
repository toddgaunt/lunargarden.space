m4_include(`macro.m4')m4_dnl
m4_define(`ROOT_DIR', `../../')m4_dnl
m4_define(`POST_NUMBER', `b/7')m4_dnl
m4_define(`POST_TITLE', `C2 Language Grammar')m4_dnl
m4_define(`POST_DATE', `2018-11-12')m4_dnl
m4_define(`POST_AUTHOR', `Todd Gaunt')m4_dnl
m4_include(`site.m4')m4_dnl
POST_HEADER
m4_changequote(`$%^?!', `!?^%$')
<div class="centered">
<!--<p>Part Two can be read <a href="8.html">here</a></p>-->
<pre>
## Introduction

Over the past two years I have been working on various compilers that were
developed to various stages of incompletion. Each language designed has been
a stepping stone towards the next language, an iterative process, that has
landed me at the current language I am developing now, C2. This may be the
language I stick with and develop a fully-featured compiler for, or it may not
be. Only time will tell.

I am, however, much more satisfied by the design and planned feature-set of
this language than all my prior ones, as I believe it hits a sweet spot
between comfort, ease-of-adoption, having a modern feature set, and the manual
control of a language like C. This is where it gets its name, C2, from
reflecting how I wish I could improve C, my favorite programming language.
Similar to C++ in spirit, but much different in method, C2 aims to heal warts
of the C language, and add modern features found in other languages that
complement what C does best: manual memory-management and performance.
Rather than pretending to maintain backwards compatibility, while the syntax
should look familiar to any ALGOL programmer, the language is quite visually
distinct to accomodate the new features and to remove language ambiguity.

Features on the roadmap include but are not limited to: lambdas,
explicit and implicit variable capture, function overloading, automatic currying,
prefix and infix operators, manual memory management, pointers and pointer arithmetic,
basic type inference, generic functions, and parameterized types.

For all of these features, the language syntax was designed to keep
refactoring code easy, be unambiguous, and be fast to parse.

## Grammar and Tokens

The grammar for C2 is very simple, and was designed with making the writing
of a hand-made recursive descent parser in mind. It should be easy to
bootstrap a programming language. A hand-written recursive-descent parser
is always easy to write. Each token type is also rather simple, and can
be expressed with a regular expression. This allows for the classic
lexer/parser split when writing an implementation of the language, since
token matching is independent of grammar context. The grammar:

                         THE C2 LANGUAGE GRAMMAR

   decimal_digit   = "0" ... "9"
   hex_digit       = "0" ... "9" | "A" ... "F" | "a" ... "f" .
   binary_lit      = "0" ("b" | "B") {"0" | "1"} .
   octal_lit       = "0" {"0" ... "7"} .
   decimal_lit     = ("1" ... "9") { decimal_digit } .
   hex_lit         = "0" ("x" | "X") hex_digit {hex_digit} .
   integer_lit     = binary_lit | octal_lit | decimal_lit | hex_lit .
   float_lit       = {decimal_digit} "." decimal_digit {decimal_digit} .
   string_lit      = `"` {UNICODE_LETTER} `"` .

   normal_ident    = ASCII_LETTER { ASCII_LETTER | "0" ... "9" } .
   prefix_ident    = "`" {UNICODE_LETTER} "`" .
   infix_ident     = "'" {UNICODE_LETTER} "'" .
   ident           = normal_ident | prefix_ident | infix_ident .

   type_primary    = "(" type ")" | normal_ident [":" type_unary ] .
   type_unary      = {"*" | "[" integer_lit "]"} type_primary .
   type_function   = type_unary {"->" type_unary} .
   type_union      = type_function {"|" type_function} .
   type_cons       = type_union {"," type_union} .
   type            = type_cons .

   block           = [ "[" [ident { "," ident }] "]" ] "{" { ";" | expr ";" } "}" .
   primary         = integer_lit
                   | float_lit
                   | string_lit
                   | ident [":"]
                   | "(" expr ")"
                   | "type" ident type
                   | "if" "(" expr ")" expr ";" {"else" "if" "(" expr ")" expr ";"} ["else" expr ";"]
                   | "for" ["(" expr [";" expr] [";" expr] ")"] expr
                   | "let" ident {"(" [ident {"," ident}] ")"} [":" type] "=" expr
                   | "goto" ident
                   | "type" ident type
                   | "lambda" {"(" [ident {"," ident}] ")"} [":" type] "=" expr
                   | block

   prefix          = { "*" | "&" | "!" | "~" | "+" | "-" } primary .
   postfix         = prefix {"[" expr "]" | "(" expr ")" | "as" type} .

   infix           = postfix {infix_ident postfix} .
   multiplicative  = infix {("*" | "/" | "%" | "<<" | ">>" | "&") infix} .
   additive        = multiplicative {("+" | "-" | "|" | "^") multiplicative} .
   comparative     = additive {("==" | "!=" | "<=" | ">=" | "<" | ">") additive} .
   logical_and     = comparative {"&&" comparative} .
   logical_or      = logical_and {"||" logical_and} .
   cons            = logical_or {"," logical_or} .
   assignment      = cons {("=" | "*=" | "/=" | "%=" | "<<=" | ">>=" | "&="
                                | "+=" | "-=" | "|=" | "^=") cons} .
   expr            = assignment .

   start           = {";" | expr ";"} EOF .

         THE C2 LANGUAGE OPERTOR PRECEDENCE (EXCLUDING PRIME)

    Category       | Operators
    ---------------+----------------------------------
    prime          | ...
    unary          | * & ! ~ + -
    infix          | INFIX_IDENT
    multiplicative | * / % << >> &
    additive       | + - | ^
    comparative    | == != <= >= < >
    logical_and    | &&
    logical_or     | ||
    cons           | ,
    assignment     | = += -= |= ^= *= /= %= <<= >>= &=

The operator precedence for the language is baked into the grammar for the
language if written using a recursive descent parser. C2 breaks some precedence
rules established from C, but for good reason. Some precedence rules broken
here are moving the bitwise '|' (or) and '&' (and) into the additive and
multiplicative categories respectively. The bit-shift operators have been moved
to the multiplicative category as well. Otherwise precedence remains identical
for pre-defined infix operators.
    
A special level of precedence was added for custom infix operators just below
unary operators, yet higher than all other binary operators. This
precedence level is for the special infix identifer form, which allows
users to enclose any identifier with single quotes to use it
as a binary operator e.g. f(5)(6) and 5 'f' 6 are equivalent excepting
precedence.

To complement this infix form, a prefix identifier form is also in the language,
allowing any identifiers enclosed by backticks to be used in the standard
prefix calling form e.g. 5 + 6 and `+`(5)(6) are equivalent in all ways
except precedence.

These special identification forms work because in C2, operators and functions
are equivalent. It is simply that certain symbols are designated as infix by
default, such as + - * and /, and the rest are designated as prefix by
default. The benefit of such a detail is that a user can define his
own infix notation, and is able to use what are traditionally thought
of as special operators in the same way as functions.

The lowest precedence operator that is still above assignment is the 'cons'
operator, or tuple construction operator, represented with , (comma). This comma
is one of the basic building blocks for how expressions in C2 are formed, and
adds a very useful data structure to the language for building data aggregates,
otherwise known as tuples.

Otherwise, most operators behave the same as they would in C, and are
by default implemented for all primitive types as appropriate.

## Examples

Below are some examples of the language grammar in action. They won't really
be explained, as that is for a later post. But it should be pretty straight-
forward to understand for someone familiar with C, C++, or Rust syntax and
semantics.

    /* Variable Declaration */

    let a : u8 = 5;    
    let b : u16 = 5;
    let c : i32 = b as i32;
    let d : f32 = 3.14;
    let e : f64 = 2.71 + (d as f64);

    /* Function Declaration */

    let f(x, y) : (u32, u32) -> u32 = {
        x / y + y / x;
    }

    let g(a)(b)(c) : f32 -> f32 -> f32 -> f32 = {
        a * b * c;
    }

    f(2, 4);
    g(1)(2)(3);

    /* Defining Aggregate and Sum Types */

    type Vec3 (x : i32, y : i32, z : i32);
    type u8_or_f32 (u : u8 | f : f32);

    /* Defining and Using an Infix Function */

    let a : Vec3 = (1, 2, 3);
    let b : Vec3 = (2, 2, 2);

    let 'cross'(a, b) : (Vec3, Vec3) -> Vec3 = (a.x * b.x, a.y * b.y, a.z * b.z);

    let c = a 'cross' b;

    /* Using an Operator as a Prefix Function */

    let x = 5;
    let y = 2;

    let z = `+`(x)(y);
    let t = `,`(20)(30);

</pre>
</div>
m4_changequote($%^?!`!?^%$, $%^?!'!?^%$)
POST_FOOTER
