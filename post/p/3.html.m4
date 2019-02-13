m4_define(`ROOT_DIR', `../../')m4_dnl
m4_define(`POST_NUMBER', `p/2')m4_dnl
m4_define(`POST_TITLE', `utest')m4_dnl
m4_define(`POST_DATE', `2019-02-10/2019-02-13')m4_dnl
m4_define(`POST_AUTHOR', `Todd Gaunt')m4_dnl
m4_include(`site.m4')m4_dnl
POST_HEADER
<h3>Libutest</h3>
<p>
utest is a simple set of macros used to facilitate writing unit tests
easily, with clear and simple error reports, and individual test registration.
</p>
<p>
This library can either be merged into an existing project because of its
single-header, two-file design, or can be installed system-wide. Either method
is supported and recommended.
</p>
<p>
The visual output of utest is not expected to be completely stable, and
should not be treated as such.
</p>
<h3>Example</h3>
<p>
An example file is provided in this repository called "example.c" that can be built using:
</p>
<pre>
make example
</pre>
<p>
It showcases library functionality with a few test successes, and a test
failure along with results reporting.
</p>
<pre>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "utest.h"

TEST_DEF(example1)
    TEST_ASSERT(1 == 1);
TEST_END

TEST_DEF(example2)
    char const *w1 = "hello";
    char const *w2 = w1;

    TEST_ASSERT(0 == strcmp("hello", "hello"));
    TEST_ASSERT(w1 == w2);
TEST_END

TEST_DEF(example_failure)
    TEST_ASSERT(1 == 2);
TEST_END

TEST_DEF(example_forked)
    for (int i = 0; i < 10; ++i)
        ;
    TEST_ASSERT(10 == i);
TEST_END

int
main(int argc, char **argv)
{
    (void)argc;
    (void)argv;
    /* Run the tests in the main thread, as if calling functions */
    TEST_RUN(example1);
    TEST_RUN(example2);
    TEST_RUN(example_failure);
    /* Run the test in a seperate process, as if calling fork() */
    TEST_FORK(example_forked);
    /* Print out test statistics at the end */
    TEST_PRINT_RESULTS();
    return 0;
}
</pre>
<h3>Rationale</h3>
<p>
A lot of unit testing frameworks are either slightly too spartan, or too
complex for my needs, and don't have a nice clean output. utest is simple,
and has room for growth as-needed.
</p>
<h3>Compatibility</h3>
<p>
utest is compatible with the C11 standard and onwards.
</p>
<h3>Installation</h3>
An easy installation command is provided with the libutest makefile:
<pre>
make install
</pre>

<h3>Changelog</h3>
<h4>v1.2.0 - 2019-02-13</h4>
<p>Add failure message for forked tests that do not exit cleanly</p>
<h4>v1.1.0 - 2019-02-10</h4>
<p>Initial release</p>

<h3>Download Links</h3>
<p>2019-02-13: <a href="FILES_DIR/2019-02-10/utest_v1.1.0.tar.gz">utest_v1.2.0.tar.gz</a></p>
<p>2019-02-10: <a href="FILES_DIR/2019-02-10/utest_v1.1.0.tar.gz">utest_v1.1.0.tar.gz</a></p>

POST_FOOTER
