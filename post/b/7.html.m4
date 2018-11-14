m4_define(`ROOT_DIR', `../../')m4_dnl
m4_define(`POST_NUMBER', `b/6')m4_dnl
m4_define(`POST_TITLE', `C2 Part One - An Introduction; Grammar and Tokens')m4_dnl
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

I am, however, much more satisfied by the design and feature-set of this
language than all my prior ones, as I believe it hits a sweet spot
between comfort, ease-of-adoption, powerful features found in modern
languages, and the manual control of a language like C. This is actually
why it is named C2; the language reflects how I wish I could improve C. Similar
to C++ in spirit, but much different in method. Rather than pretending to
maintain backwards compatibility, that idea is eschewed in favor of simply
maintaining familiar syntax that is only changed as necessary to reduce parser
ambiguity and leveraging new features that are worth the change.

Features on the planning block include but are not limited to: lambdas,
explicit & implicit variable capture, function overloading, automatic currying,
prefix & infix operators, manual memory management, pointers & pointer arithmetic,
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

The lowest precedence operator that is still above assignment is the 'cons'
operator, or tuple construction operator, represented with , (comma). This comma
is one of the basic building blocks for how expressions in C2 are formed, and
adds a very useful data structure to the language in the form of easy
to define and construct data aggregates, otherwise known as tuples.

Otherwise, most operators behave the same as they would in C, and are
by default implemented for all primitive types as appropriate.

## Examples

Below are some examples of the language grammar in action. They won't really
be explained, as that is for a later post. But it should be pretty straight-
forward to understand for someone familiar with C, C++, or Rust syntax and
semantics.

	-- Variable Declaration --

	let a : u8 = 5;	
	let b : u16 = 5;
	let c : i32 = b as i32;
	let d : f32 = 3.14;
	let e : f64 = 2.71 + (d as f64);

	-- Function Definition and Overloading --

	let f = fn (x : u32, y : u32) -> u32 {
		x / y + y / x;
	}

	let f = fn (x : f32, y : f32) -> f32 {
		x / y + y / x;
	}

	f(2, 4);
	f(3.14, 2.71);

	-- Defining Aggregate and Sum Types --

	type Vec3 = (x : i32, y : i32, z : i32);
	type u8_or_f32 = u : u8 | f : f32;

	-- Defining and Using an Infix Function --

	let a : Vec3 = (1, 2, 3);
	let b : Vec3 = (2, 2, 2);

	let 'cross' = fn (a : Vec3, b : Vec3) -> Vec3{
		let ret : Vec3;
		ret.x = a.x * b.x;
		ret.y = a.y * b.y;
		ret.z = a.z * b.z;
		ret;
	}

	let c = a 'cross' b;

	-- Using an Operator as a Prefix Function --

	let x = 5;
	let y = 2;

	let z = `+`(x)(y);

</pre>
</div>
m4_changequote($%^?!`!?^%$, $%^?!'!?^%$)
POST_FOOTER
