m4_include(`macro.m4')m4_dnl
m4_define(`ROOT_DIR', `')m4_dnl
m4_include(`site.m4')m4_dnl
<!DOCTYPE html>
<!--Author: Todd Gaunt-->
SITE_HEADER(`C Style Guide')
<h3>Notice</h3>

This is a modification of the style guide provided by suckless.org.

<h3>File Layout</h3>
<ul>
    <li>Comment with LICENSE</li>
    <li>Headers</li>
    <li>Macros</li>
    <li>Types</li>
    <li>Function declarations
        <ul>
        <li>Include variable names</li>
        <li>For short files these can be left out</li>
        <li>Group/order in logical manner</li>
        </ul></li>
    <li>Global variables</li>
    <li>Function definitions in same order as declarations</li>
    <li>main</li>
</ul>

<h3>C Features</h3>
<ul>
    <li>Use C11 without extensions</li>
    <li>Use POSIX.1-2008</li>
    <li>Do not mix declarations and code</li>
    <li>Do not use for loop initial declarations</li>
    <li>Use /* */ for comments, not //</li>
    <li>Use <code>#ifdef 0</code> matched with <code>#endif</code> to "comment out" code if needed</li>
    <li>Variadc functions and macros are acceptable, but require safety</li>
</ul>

<h3>Blocks</h3>
<ul>
    <li>All variable declarations at the beginning of a block</li>
    <li>{ on same line preceded by single space (except functions)</li>
    <li>} on own line unless continuing statement (if else, do while, ...)</li>
    <li>Use block for single statement iff</li>
    <!--
        Inner statement needs a block

        for (;;) {

        if (foo) {

        bar;
        baz;

        }

        }

        Another branch of the same statement needs a block

        if (foo) {

        bar;

        } else {

        baz; qux;

        }
        -->
</ul>

<h3>Indentation and Line Length</h3>
<ul>
    <li>Keep line to a maximum length of 80 columns</li>
    <li>Use 4 spaces for indentation</li>
    <li>Two indents should be used when wrapping statements past 80 columns</li>
    <li>Only string literals used as error messages are an exception this rule</li>
</ul>
<!--

Functions

    Return type and modifiers on own line
    Function name and argument list on next line
    Opening { on own line (function definitions are a special case of blocks as they cannot be nested)
    Functions not used outside translation unit should be declared and defined static

Variables

    Global variables not used outside translation unit should be declared static
    In declaration of pointers the * is adjacent to variable name, not type

Keywords

    Use a space after if, for, while, switch (they are not function calls)
    Do not use a space after the opening ( and before the closing )
    Always use () with sizeof
    Do not use a space with sizeof() (it does act like a function call)

Switch

    Do not indent cases another level
    Comment cases that FALLTHROUGH

Headers

    Place system/libc headers first in alphabetical order
        If headers must be included in a specific order comment to explain
    Place local headers after an empty line
    When writing and using local headers
        Do not use #ifndef guards
        Instead ensure they are included where and when they are needed
        Read https://talks.golang.org/2012/splash.article#TOC_5.
        Read http://plan9.bell-labs.com/sys/doc/comp.html

User Defined Types

    Do not use type_t naming (it is reserved for POSIX and less readable)
    Typedef opaque structs
    Do not typedef builtin types
    Capitalize the type name

    Typedef the type name, if possible without first naming the struct

    typedef struct {
    	double x, y, z;
    } Point;

Line Length

    Keep lines to reasonable length (current debate as to reasonable)
    If your lines are too long your code is likely too complex

Tests and Boolean Values

    Do not test against NULL explicitly
    Do not test against 0 explicitly
    Do not use bool types (stick to integer types)

    Assign at declaration when possible

    Type *p = malloc(sizeof(*p));
    if (!p)
    hcf();

    Otherwise use compound assignment and tests unless the line grows too long

    if (!(p = malloc(sizeof(*p))))
    	hcf();

Handling Errors

    When functions return -1 for error test against 0 not -1

    if (func() < 0)
    hcf();

    Use goto to unwind and cleanup when necessary instead of multiple nested levels
    return or exit early on failures instead of multiple nested levels
    Unreachable code should have a NOTREACHED comment
    Think long and hard on whether or not you should cleanup on fatal errors

Enums vs #define

    Use enums for values that are grouped semantically and #define otherwise

    #define MAXSZ  4096
    #define MAGIC1 0xdeadbeef

    enum {

    	DIRECTION_X,
    	DIRECTION_Y,
    	DIRECTION_Z
    };
-->
SITE_FOOTER
