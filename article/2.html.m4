m4_define(`ROOT_DIR', `../')m4_dnl
m4_define(`POST_NUMBER', `2')m4_dnl
m4_define(`POST_TITLE', `Generic Vectors in C')m4_dnl
m4_define(`POST_DATE', `2018-02-22')m4_dnl
m4_define(`POST_AUTHOR', `Todd Gaunt')m4_dnl
m4_include(`site.m4')m4_dnl
POST_HEADER
<p>Creating generic types and procedures in C is generally done two ways: With
code generation (cpp, m4) or <i style="white-space: nowrap;">void *</i>.
The second method, <i style="white-space: nowrap;">void *</i>
has the benefit of only having to compile once, but it throws type-safety out the
window. Worse, however, is that for something like a vector
it can only store pointer-sized elements in the vector, which causes extra
indirection when trying to store a vector of elements larger than pointers.

<p>I decided to write generic vector using cpp macros that uses some C11 syntax tricks
to create a very C++ esque vector type that fits inside a single
<a href="FILES_DIR/2018-02-22/vec.txt">C header file</a>, and is only 60 lines
of code.</p>

<h3>Example</h3>
<pre><code class="C">#include &lt;stdint.h&gt;
#include &lt;stdio.h&gt;
#include &lt;stdlib.h&gt;
#include &lt;string.h&gt;

#include "vec.h"

typedef Vec(char) Vecchar;

int
main()
{
	int x;

	Vec(int) vector = VEC_INIT;
	VEC_RESERVE(&amp;vector, 20);
	VEC_PUSH(&amp;vector, 5);
	x = *VEC_GET(&amp;vector, 0);
	printf("%d\n", x);
}</code></pre>
POST_FOOTER
