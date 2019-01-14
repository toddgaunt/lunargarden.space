m4_define(`ROOT_DIR', `../../')m4_dnl
m4_define(`POST_NUMBER', `p/1')m4_dnl
m4_define(`POST_TITLE', `libcpso')m4_dnl
m4_define(`POST_DATE', `2019-01-14')m4_dnl
m4_define(`POST_AUTHOR', `Todd Gaunt')m4_dnl
m4_include(`site.m4')m4_dnl
POST_HEADER
<h3>Description</h3>
<p>This is a small library implementing a particle swarm optimization algorithm
in C89. This library can either be installed and linked with, or simply be
copied into another project's source tree since it consists of only two files.
The particle swarm simulation functions provided can be used in a program to
heuristically minimize functions.</p>


<h3>Usage and Configuration</h3>
<p>First include the cpso header, configure the swarm, then call the cpso
initialization function. Then either cpso_step or cpso_run can be called
to run the particle swarm simulation either step-wise or until a set number
of iterations respectively.</p>

<p>The details for the swarm configuration struct are shortly described in the 
"cpso.h" header file.</p>

<h3>Examples</h3>
<p>Within the distribution tarball, there is a file "demo.c" that displays usage
of the library with a randomizing fitness function. This demo showcases use of
all provided library functions (as of the 1.0.0 release), can be built with
'make demo', and run by executing the 'demo' binary created.</p>


<h3>Installation</h3>
<p>No external dependencies are required for this library other than a C89
compliant libc, make, compiler. A config.mk file is provided which allows for
easy editing of compilation flags, linking options, and installation
directories. The library can be built with 'make all', installed
with 'make install', and uninstalled with 'make uninstall'. Note that any build
configuration changes made to config.mk must be the same for both the install
and uninstall targets, otherwise they may not work as desired.</p>

<h3>Download Links</h3>
<p>2019-01-14: <a href="FILES_DIR/2019-01-14/cpso-v1.0.0.tar.gz">cpso-v1.0.0.tar.gz</a></p>

POST_FOOTER
