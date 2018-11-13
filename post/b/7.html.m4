m4_define(`ROOT_DIR', `../../')m4_dnl
m4_define(`POST_NUMBER', `b/6')m4_dnl
m4_define(`POST_TITLE', `Grammar of the C2 Programming Language')m4_dnl
m4_define(`POST_DATE', `2018-05-12')m4_dnl
m4_define(`POST_AUTHOR', `Todd Gaunt')m4_dnl
m4_include(`site.m4')m4_dnl
POST_HEADER
m4_changequote(`$%^?!', `!?^%$')
<div class="centered">
<pre>
Over the past two years I have been working on various compilers that were
developed to various stages of incompletion. Each language designed has been
a stepping stone towards the next language, an iterative process, that has
landed me at the current language I am developing now, C2. This may be the
language I stick with and develop a fully-featured compiler for, or it may not
be. Only time will tell.

I am, however, much more satisfied by the design and feature-set of this
language than all my prior ones, as I believe it hits a sweet spot
between comfort, ease-of-adoption, powerful features found in modern
languages, and the manual control of a language like C. This is actually
why it is named C2; the language reflects how I wish I could improve C. Similar
to C++ in spirit, but much different in method. Rather than pretending to
maintain backwards compatibility, that idea is eschewed in favor of simply
maintaining familiar syntax that is only changed as necessary to reduce parser
ambiguity and leveraging new features that are worth the change.

The grammar for C2 is very simple, and was designed with making the writing
of a hand-made recursive descent parser in mind. It should be easy to
bootstrap a programming language. A hand-written recursive-descent parser
is always easy to write. Each token type is also rather simple, and can
be expressed with a regular expression. This allows for the classic
lexer/parser split when writing an implementation of the language, since
token matching is independent of grammar context. The grammar:

                         THE C2 LANGUAGE GRAMMAR

    start           :(expr ';') EOF
    ;
    expr            :'let' ident ((':' type ['=' expr]) | ("=" expr)) ['as' type]
		    | assignment ['as' type]
    ;
    assignment      :cons (('=' | '+=' | '-=' | '|=' | '^='
		    | '*=' | '/=' | '%=' | '<<=' | '>>=' | '&=') cons)*
    ;
    cons            :logical_or (',' logical_or)*
    ;
    logical_or      :logical_and ('||' logical_and)*
    ;
    logical_and     :comparative ('&&' comparative)*
    ;
    comparative     :additive (('==' | '!=' | '<=' | '>=' | '<' | '>') additive)*
    ;
    additive        :multiplicative (('+' | '-' | '|' | '^') multiplicative)*
    ;
    multiplicative  :infix (('*' | '/' | '%' | '<<' | '>>' | '&') infix)*
    ;
    infix           : unary (INFIX_IDENT unary)*
    ;
    unary           : ('*' | '&' | '!' | '~' | '+' | '-') unary | prime
    ;
    prime           : ['fn' type] ['[' [ident] [',' ident]* ']'] '{ stmt* '}
		    | '(' expr ')'
		    | BINARY_LIT | INTEGER_LIT | HEX_LIT
		    | RADIX_LIT
		    | STRING_LIT
		    | ALPHANUMERIC_IDENT | PREFIX_IDENT
		    | expr ('(' expr ')')*
    ;
    ident           : ALPHANUMERIC_IDENT | PREFIX_IDENT | INFIX_IDENT
    ;
    type            : type_or ('->' type_or)*
    ;
    type_cons       : type_prime (',' type_prime)*
    ;
    type_union      : type_prime ('|' type_prime)*
    ;
    type_prime      : ALPHANUMERIC_IDENT [':' type]
    ;

		     THE C2 TOKEN REGULAR EXPRESSIONS

    Token              | Regex                 | Example
    -------------------+-----------------------+--------
    ALPHANUMERIC_IDENT | [a-zA-Z][a-zA-Z0-9_]* | var_name
    PREFIX_IDENT       | '[^']'                | `A*`
    INFIX_IDENT        | `[^`]*`               | 'cross product'
    BINARY_LIT         | 0b[01]+               | 0b0101010
    INTEGER_LIT        | [0-9]+                | 42
    HEX_LIT            | 0x[a-fA-F0-9]+        | 0x2A
    RADIX_LIT          | [0-9]*\.[0-9]+        | .42
    STRING_LIT         | "[^"]"                | "hello world\n"


	     THE C2 LANGUAGE OPERTOR PRECEDENCE (EXCLUDING PRIME)

    Category       | Operators
    ---------------+----------------------------------
    prime          | ...
    unary          |  * & ! ~ + -
    infix          |  '[^']'
    multiplicative | * / % << >> &
    additive       | + - | ^
    comparative    | == != <= >= < >
    logical_and    | &&
    logical_or     | ||
    cons           | ,
    assignment     | = += -= |= ^= *= /= %= <<= >>= &=

The operator precedence for the language is baked into the grammar for the
language if written using a recursive descent parser. Unlike many languages,
C2 breaks some precedence rules established from C, but for good reason. Some
precedence rules broken here are moving the bitwise '|' (or) and '&' (and)
into the additive and multiplicative categories respectively. The bit-shift
operators have been moved to the multiplicative category as well. Otherwise
precedence remains identical for pre-defined infix operators. A special
level of precedence was added for custom infix operators just below
unary operators, yet higher than all other binary operators. This
precedence level is for the special INFIX_IDENT form, which allows
users to use any identifier enclosed by single quotes, including pre-defined
binary operators, in infix form given that it is a binary function e.g.
f(5)(6) and 5 'f' 6 are equivalent.

To complement this infix form, the PREFIX_IDENT form is also in the language,
allowing any characters enclosed by backticks/grave accents to be used in
the prefix calling form e.g. 5 + 6 and `+`(5)(6) are equivalent in all ways
except precedence.

These special identification forms work because in C2, operators and functions
are equivalent. It is simply that certain symbols are designated as infix by
default, such as + - * and /, and the rest are designated as prefix by
default. The benefit of such a detail is that a user can define his
own infix notation, and is able to use what are traditionally thought
of as special operators in the same way as functions.

This is all I will be covering in this post. A seperate post
will be written sometime in the future covering the semantics of the
language. Features such as function overloading, automatic currying,
type inference, tail-call elimination, generic functions, generic types,
and how they all mesh together will be covered at a later date.
</pre>
</div>
m4_changequote($%^?!`!?^%$, $%^?!'!?^%$)
POST_FOOTER
