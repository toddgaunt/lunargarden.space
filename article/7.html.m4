m4_define(`ROOT_DIR', `../')m4_dnl
m4_define(`POST_NUMBER', `7')m4_dnl
m4_define(`POST_TITLE', `Muse Virtual Machine ISA')m4_dnl
m4_define(`POST_DATE', `2018-09-19')m4_dnl
m4_define(`POST_AUTHOR', `Todd Gaunt')m4_dnl
m4_include(`site.m4')m4_dnl
POST_HEADER
<p>After writing an experimental virtual machine I named
Dynamic Virtual Machine (Abbreviated DVM), and learning a lot about virtual
machine design along the way, It was time to write a virtual machine that
countered the design decisions made in DVM to learn about the paths not taken.
This meant a register machine instead of a stack machine, an integer based
instruction set rather than a complex object based instruction set,
fully byte-addressable memory rather than object-addressable memory,
and no object tags to facilitate machine level dynamic type checking. 
This post, however, is not about describing the details of DVM in detail. Rather
it is about the Muse Virtual Machine (Abbreviated MVM) ISA and its design. DVM
may be brought up to compare and contrast to, however in such a case the feature
being compared in DVM will be fully explained.</p>

<p>MVM is a virtual machine implementing the Muse ISA, a RISC load/store
instruction set architecture. It is meant to be a target for compilers, while
being designed to be run similar to the JVM, utilizing the underlying
operating system-calls underneath with little overhead on a host operating
system, or run on completely virtualized hardware with no access the underlying
system. The goal of the Muse ISA was to allow for a virtual machine to be
written easily in very few lines of code, and to keep instructions simple and
easy to translate to native machine instructions.</p>

<h3> Muse ISA </h3>

<p>The machine specified by Muse ISA is to have 32 addressable integer
registers, 32 addressable floating point registers, a program counter,
an instruction register, and a fixed-size stack for data/code to be addressed
directly proceeding the section of memory used for program data.
Each instruction is fixed 32bits wide, and can be one of four formats.</p>

<p>Memory is byte-addressable. When executing a program, however, the program
counter starts at address 0, and increments in values of 4 after decoding,
but before execution of, each instruction. So while the program counter
increments in bytes, it is always aligned to 4 bytes, or 32 bits. No instruction
can change this alignment, guaranteeing program counter alignment at all times.</p>

POST_FOOTER
