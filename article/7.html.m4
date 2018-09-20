m4_define(`ROOT_DIR', `../')m4_dnl
m4_define(`POST_NUMBER', `7')m4_dnl
m4_define(`POST_TITLE', `Muse Virtual Machine ISA')m4_dnl
m4_define(`POST_DATE', `2018-09-20')m4_dnl
m4_define(`POST_AUTHOR', `Todd Gaunt')m4_dnl
m4_include(`site.m4')m4_dnl
POST_HEADER

<h3>Introduction</h3>

<p>After writing an experimental virtual machine I named
Dynamic Virtual Machine (Abbreviated DVM), and learning a lot about virtual
machine development along the way, It was time to write a virtual machine that
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
system, or run as completely virtualized hardware with no access the underlying
system. The goal of the Muse ISA was to allow for a virtual machine to be
written easily in very few lines of code, and to keep instructions simple and
easy to translate to native machine instructions.</p>

<h3>Muse ISA</h3>

<p>The machine specified by Muse ISA is to have 32 addressable integer
registers, 32 addressable floating point registers, a program counter,
an instruction register, and a fixed-size stack for data/code to be addressed
directly proceeding the section of memory used for program data.
Each instruction is fixed 32bits wide, and can be one of four
<a href="#instruction-formats">formats</a>.</p>

<p>A register machine model was chosen over a stack machine model for MVM, for
a few opinionated reasons. The ideal machine to work with is a memory-to-memory
machine, that is a machine where instructions directly address and operate on
memory, rather than having some intermediate location such as registers or
a stack. The problem with this kind of model is instruction size, as each
address operand in an instruction will require 64 bits, so a fixed-width length
instruction set would waste memory. This means some sort of variable sized
instruction set must be used, or multiple instructions would be required to
be able to address all addresses.</p>

<p>Since one of the goals of Muse ISA was
simplicity, both in encoding, decoding, and execution, this means that a
variable sized instruction set was out of the question. So now the option left
is to consider using multiple smaller instructions to be able to address all
memory addresses. Well, in order to use multiple instructions to address large
memory ranges, the previous instruction's immediate value would need to be
stored somewhere, perhaps in a memory cell that can be addressed by a small
immediate value. We could call it a register... and that is why Muse ISA is
designed as a register machine. It is the closest architecture to a
memory-to-memory machine, and the instruction size is kept to a reasonable
fixed-width of 32 bits.</p>

<p>Well what about a stack machine? Surely that could be simpler and have even
fewer bits in the instruction width. Indeed, a stack machine can. DVM, the
virtual machine I made before MVM, has an instruction size of 16 bits in its
stack-based architecture. However, one problem with a 16 bit instruction width is that
there is no room to store immediate values over 16 bits, especially if there
are opcodes in those instructions. So there is no reason to use a stack machine
because of instruction size, but there is a more definitive reason why a stack
machine model was not used for Musa ISA. Since Muse ISA
is about simplicity, and stack machine instructions become more complex as they
must manage a stack pointer, a stack machine model would not have done the
job.</p>

<p>In MVM, memory is byte-addressable. When executing a program the program
counter starts at address 0, and increments in values of 4 after decoding,
but before execution of, each instruction. So while the program counter
is in units of bytes, it is always divisible by 4 bytes, or 32 bits. No instruction
can change this alignment, guaranteeing program counter alignment with
instructions at all times. As a side-note, this means misaligned instructions
cannot be executed by MVM.</p>

<p>The rationale behind keeping this alignment is that doing so will never
cause misalignment performance penalties, and prevent instructions from being
split across two memory cells. Keeping 32-bit alignment from address 0 also extends the
minimum and maximum of the range of addresses that a jump instruction can reach.
Jumps are the only way to modify the program counter, are relative
to the program counter, and are always done in units of 4 bytes. This maintains
the property of an aligned program counter, and extends changes the max/min
value a <a href="#standard-instructions">JMP</a> can use from +-33,553,332, to
+-134,217,728, or 25 bits to 27 bits for <a href="#instruction-formats">format 1</a>,
and 15 to 17 bits for <a href="#instruction-formats">format 2</a>.</p>

<p>For the registers, there are a few registers reserved for important tasks.
These are namely the stack pointer
<em><a href="#registers-and-calling-conventions">sp</a></em>, and the
memory-mapped I/O pointer
<em><a href="#registers-and-calling-conventions">io</a></em> among others.
These pointers are set to come directly after the program data. The stack
pointer points a distance away from the end of the program data, where
that distance is however much user of the virtual machine specifies (by default
it is 1MB). This leaves 1MB for the stack to grow downwards into. Above that
lies the I/O pointer, which has a similar configuration. The distance the I/O
pointer lies above the stack is dependent on the number and kind of I/O
devices supported by the system. When running MVM as a slim virtual machine,
relying on the underlying OS syscalls, the I/O pointer is set to the same
address as the stack pointer, and shouldn't be used. However, when running the
VM with the intent of virtualizing hardware and running a guest OS, the I/O
pointer will first point to data that describes the devices connected to the
VM. The first of these devices will always be a 4-byte-mapped terminal device
for the most basic I/O.</p>

<h3>Syntax and Some Programs</h3>

<p>MVM uses a fairly standard-looking assembler syntax. Each line
can contain up to four grammatical objects. A Label, which is optional, can
be followed by an Operation, which is followed by at least one operand but
potentially many. Finally the line is ended with an optional comment.
Omitting everything except for the comment is also acceptable:</p>

<p>[ LABEL : ] SYMBOL OPERAND [ , OPERAND ]* [ # STRING ]"</p>

<p>There are no required sigils to signal certain literals or symbols, however
all registers are prefixed with '%' as a visual convention. For example, to
refer to register <em><a href="#registers-and-calling-conventions">ra</a></em>, one
would write it as "%ra" in MVM assembler language file. Other symbols, such
as opcodes, directives, and labels, do not have any prefix convention, nor
require a prefix from the syntax.</p>

<h4>A program that loops 1,000,000 times</h4>
<pre>
		L32  %t0, x
	loop:   SUBI %t0, %t0, 1
		JEZ  %t0, exit
		JMP loop
	exit:   HALT
	x: i32 1000000
</pre>

<h4>A program that uses the operating system to print "hello world"</h4>
<pre>
		LI %a0, 1         # Load the stdout file descriptor
		LI %a1, 12        # Load the number of characters to be
		LI %a2, x         # Load the address of the string to be transmitted
		SYSCALL 1
	exit:   HALT
	x: str "hello world\n"
</pre>

<p>The rest of this article consists of some reference tables for the Muse ISA.
This article serves as an introduction to Muse ISA, not as the full documentation.
Although this is an incomplete description of the Muse ISA, as the design
has been not been finalized, the most stable design decisions of the machine
have been described. The remaining work that needs to be done is decide on
floating point comparison instructions, figure out what function the registers
between
<em><a href="#registers-and-calling-conventions">a7</a></em>
<em><a href="#registers-and-calling-conventions">ra</a></em>
should perform, the way in which global data is stored, and finally the method
that the I/O section of memory specifies where each device is located to the
programmer.</p>

<h3>Muse ISA Reference Tables</h3>

<h5 id="registers-and-calling-conventions">Registers and Calling Conventions:</h5>
<div>
<table>
	<tr>
	<th>Register Index</th>
	<th>Name</th>
	<th>Description</th>
	<th>Volatile between calls?</th>
	</tr>
	<tr>
	<td>r0</td>
	<td>zero</td>
	<td>Hardwired to zero</td>
	<td>No</td>
	</tr>
	<tr>
	<td>r1</td>
	<td>sp</td>
	<td>Stack Pointer</td>
	<td>No</td>
	</tr>
	<tr>
	<td>r2</td>
	<td>gp</td>
	<td>Global Pointer</td>
	<td>No</td>
	</tr>
	<tr>
	<td>r3</td>
	<td>tp</td>
	<td>Thread Pointer</td>
	<td>No</td>
	</tr>
	<tr>
	<td>r4</td>
	<td>io</td>
	<td>Memory mapped I/O pointer</td>
	<td>No</td>
	</tr>
	<tr>
	<td>r5</td>
	<td>fp</td>
	<td>Frame Pointer</td>
	<td>No</td>
	</tr>
	<tr>
	<td>r6-r15</td>
	<td>t0-t9</td>
	<td>Temporaries</td>
	<td>Yes</td>
	</tr>
	<tr>
	<td>r16-r23</td>
	<td>a0-a7</td>
	<td>Function Argument/Return Values</td>
	<td>Yes</td>
	</tr>
	<tr>
	<td>r31</td>
	<td>ra</td>
	<td>Return Address</td>
	<td>No</td>
	</tr>
</table>
</div>

<h5 id="#instruction-formats">Instruction Formats:</h5>
<div>
<table>
	<tr>
	<th>Format</th>
	<th>Immediate</th>
	<th>Register 3</th>
	<th>Register 2</th>
	<th>Register 1</th>
	<th>Opcode</th>
	</tr>
	<tr>
	<td>1</td>
	<td>26 bits</td>
	<td>0 bits</td>
	<td>0 bits</td>
	<td>0 bits</td>
	<td>6 bits</td>
	</tr>
	<tr>
	<td>2</td>
	<td>21 bits</td>
	<td>0 bits</td>
	<td>0 bits</td>
	<td>5 bits</td>
	<td>6 bits</td>
	</tr>
	<tr>
	<td>3</td>
	<td>16 bits</td>
	<td>0 bits</td>
	<td>5 bits</td>
	<td>5 bits</td>
	<td>6 bits</td>
	</tr>
	<tr>
	<td>4</td>
	<td>11 bits</td>
	<td>5 bits</td>
	<td>5 bits</td>
	<td>5 bits</td>
	<td>6 bits</td>
	</tr>
</table>
</div>

<h5 id="standard-instructions">Standard Instructions:</h5>
<div>
<table>
	<tr>
	<th>Opcode</th>
	<th>Encoding</th>
	<th>Format</th>
	<th>Description</th>
	</tr>
	<tr>
	<td>NOP</td>
	<td>0x00</td>
	<td>1</td>
	<td>Do nothing</td>
	</tr>
	<tr>
	<td>HALT</td>
	<td>0x01</td>
	<td>1</td>
	<td>Halt machine execution</td>
	</tr>
	<tr>
	<td>SYSCALL</td>
	<td>0x02</td>
	<td>1</td>
	<td>Call the operating system routine specified with <strong>im</strong></td>
	</tr>
	<tr>
	<td>JMP</td>
	<td>0x03</td>
	<td>1</td>
	<td>Add <strong>im</strong> to pc</td>
	</tr>
	<tr>
	<td>JAL</td>
	<td>0x04</td>
	<td>1</td>
	<td>Store <em>pc</em> in <em>rx</em>, then adds <strong>im</strong> to <em>pc</em></td>
	</tr>
	<tr>
	<td>JR</td>
	<td>0x05</td>
	<td>2</td>
	<td>Set <em>pc</em> to the value of register <strong>r1</strong></td>
	</tr>
	<tr>
	<td>JRL</td>
	<td>0x06</td>
	<td>2</td>
	<td>Store <em>pc</em> in <em>rx</em>, then set <em>pc</em> to value in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>JEZ</td>
	<td>0x07</td>
	<td>2</td>
	<td>If the value in <strong>r1</strong> equals 0, add <strong>im</strong> to <em>pc</em></td>
	</tr>
	<tr>
	<td>JNZ</td>
	<td>0x08</td>
	<td>2</td>
	<td>If the value in <strong>r1</strong> does not equals 0, add <strong>im</strong> to <em>pc</em></td>
	</tr>
	<tr>
	<td>JLZ</td>
	<td>0x09</td>
	<td>2</td>
	<td>If the value in <strong>r1</strong> is less than 0, add <strong>im</strong> to <em>pc</em></td>
	</tr>
	<tr>
	<td>JGZ</td>
	<td>0x0a</td>
	<td>2</td>
	<td>If the value in <strong>r1</strong> is greater than 0, add <strong>im</strong> to <em>pc</em></td>
	</tr>
	<tr>
	<td>LUI</td>
	<td>0x0b</td>
	<td>2</td>
	<td>Load <strong>im</strong> and store it in bits 17-42 of <strong>r1</strong></td>
	</tr>
	<tr>
	<td>L8</td>
	<td>0x0c</td>
	<td>3</td>
	<td>Load the next 8 bits of the value in <strong>r2</strong> + <strong>im</strong> into <strong>r1</strong></td>
	</tr>
	<tr>
	<td>L16</td>
	<td>0x0d</td>
	<td>3</td>
	<td>Load the next 16 bits of the value in <strong>r2</strong> + <strong>im</strong> into <strong>r1</strong></td>
	</tr>
	<tr>
	<td>L32</td>
	<td>0x0e</td>
	<td>3</td>
	<td>Load the next 32 bits of the value in <strong>r2</strong> + <strong>im</strong> into <strong>r1</strong></td>
	</tr>
	<tr>
	<td>L64</td>
	<td>0x0f</td>
	<td>3</td>
	<td>Load the next 64 bits of the value in <strong>r2</strong> + <strong>im</strong> into <strong>r1</strong></td>
	</tr>
	<tr>
	<td>S8</td>
	<td>0x10</td>
	<td>3</td>
	<td>Store the lower 8 bits of the value in <strong>r1</strong> into the memory addressed by <strong>r2</strong> + <strong>im</strong></td>
	</tr>
	<tr>
	<td>S16</td>
	<td>0x11</td>
	<td>3</td>
	<td>Store the lower 16 bits of the value in <strong>r1</strong> into the memory addressed by <strong>r2</strong> + <strong>im</strong></td>
	</tr>
	<tr>
	<td>S32</td>
	<td>0x12</td>
	<td>3</td>
	<td>Store the lower 32 bits of the value in <strong>r1</strong> into the memory addressed by <strong>r2</strong> + <strong>im</strong></td>
	</tr>
	<tr>
	<td>S64</td>
	<td>0x13</td>
	<td>3</td>
	<td>Store the lower 64 bits of the value in <strong>r1</strong> into the memory addressed by <strong>r2</strong> + <strong>im</strong></td>
	</tr>
	<tr>
	<td>NOT</td>
	<td>0x14</td>
	<td>3</td>
	<td>Invert the bytes of the value in <strong>r2</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>ADDI</td>
	<td>0x15</td>
	<td>3</td>
	<td>Add <strong>im</strong> to the value in register <strong>r2</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>SUBI</td>
	<td>0x16</td>
	<td>3</td>
	<td>Subtract <strong>im</strong> to the value in <strong>r2</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>ANDI</td>
	<td>0x17</td>
	<td>3</td>
	<td>Bitwise AND <strong>im</strong> to the value in <strong>r2</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>ORI</td>
	<td>0x18</td>
	<td>3</td>
	<td>Bitwise OR <strong>im</strong> to the value in <strong>r2</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>XORI</td>
	<td>0x19</td>
	<td>3</td>
	<td>Bitwise XOR <strong>im</strong> to the value in <strong>r2</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>ADD</td>
	<td>0x1a</td>
	<td>4</td>
	<td>Add the value in <strong>r2</strong> to the value in <strong>r3</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>ADDU</td>
	<td>0x1b</td>
	<td>4</td>
	<td>Add the unsigned value in <strong>r2</strong> to the value in <strong>r3</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>SUB</td>
	<td>0x1c</td>
	<td>4</td>
	<td>Subtract the value in <strong>r3</strong> from the value in <strong>r2</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>SUBU</td>
	<td>0x1d</td>
	<td>4</td>
	<td>Subtract the unsigned value in <strong>r3</strong> from the value in <strong>r2</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>MUL</td>
	<td>0x1e</td>
	<td>4</td>
	<td>Multiply the value in <strong>r2</strong> to the value in <strong>r3</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>MULU</td>
	<td>0x1f</td>
	<td>4</td>
	<td>Multiply the unsigned value in <strong>r2</strong> by the value in <strong>r3</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>DIV</td>
	<td>0x20</td>
	<td>4</td>
	<td>Divide the value in <strong>r2</strong> by the value in <strong>r3</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>DIVU</td>
	<td>0x21</td>
	<td>4</td>
	<td>Divide the unsigned value in <strong>r2</strong> to the value in <strong>r3</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>MOD</td>
	<td>0x22</td>
	<td>4</td>
	<td>Modulo the value in register <strong>r2</strong> by the value in <strong>r3</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>SLL</td>
	<td>0x23</td>
	<td>4</td>
	<td>Shift left logically the value in <strong>r2</strong> by the value in <strong>r3</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>SRL</td>
	<td>0x24</td>
	<td>4</td>
	<td>Shift right logically the value in <strong>r2</strong> by the value in <strong>r3</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>SLA</td>
	<td>0x25</td>
	<td>4</td>
	<td>Shift left arithmetically the value in <strong>r2</strong> by the value in <strong>r3</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>SRA</td>
	<td>0x26</td>
	<td>4</td>
	<td>Shift right arithmetically the value in <strong>r2</strong> by the value in <strong>r3</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>AND</td>
	<td>0x27</td>
	<td>4</td>
	<td>Bitwise AND the value in <strong>r2</strong> by the value in <strong>r3</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>OR</td>
	<td>0x28</td>
	<td>4</td>
	<td>Bitwise OR the value in <strong>r2</strong> by the value in <strong>r3</strong>, then store the result in <strong>r1</strong></td>
	</tr>
	<tr>
	<td>XOR</td>
	<td>0x29</td>
	<td>4</td>
	<td>Bitwise XOR the value in <strong>r2</strong> by the value in <strong>r3</strong>, then store the result in <strong>r1</strong></td>
	</tr>
</table>
</div>

<h5>Floating Point Unit Instructions:</h5>
<div>
<table>
	<tr>
	<th>Opcode</th>
	<th>Encoding</th>
	<th>Format</th>
	<th>Description</th>
	</tr>
	<tr>
	<td>LCF64</td>
	<td>0x2a</td>
	<td>3</td>
	<td>Load the next 64 bits of the value addressed by integer register
		<strong>r2</strong> + <strong>im</strong> into floating point
		register <strong>r1</strong></td>
	</tr>
	<tr>
	<td>SCF64</td>
	<td>0x2b</td>
	<td>3</td>
	<td>Store the lower 64 bits of floating point register
		<strong>r1</strong> into the location addressed by integer
		register <strong>r2</strong> + <strong>im</strong></td>
	</tr>
	<tr>
	<td>ADDF</td>
	<td>0x2c</td>
	<td>4</td>
	<td>Add the value of floating point register <strong>r2</strong> to the
		value of floating point register <strong>r3</strong>, then
		store the result in floating point register
		<strong>r1</strong></td>
	</tr>
	<tr>
	<td>SUBF</td>
	<td>0x2d</td>
	<td>4</td>
	<td>Subtract the value of floating point register <strong>r2</strong>
		to the value of floating point register <strong>r3</strong>,
		then store the result in floating point register
		<strong>r1</strong></td>
	</tr>
	<tr>
	<td>MULF</td>
	<td>0x2e</td>
	<td>4</td>
	<td>Multiply the value of floating point register <strong>r2</strong>
		to the value of floating point register <strong>r3</strong>,
		then store the result in floating point register
		<strong>r1</strong></td>
	</tr>
	<tr>
	<td>DIVF</td>
	<td>0x2f</td>
	<td>4</td>
	<td>Divide the value of floating point register <strong>r2</strong> to
		the value of floating point register <strong>r3</strong>, then
		store the result in floating point register
		<strong>r1</strong></td>
	</tr>
</table>
</div>

<h5>Standard Assembler Directives:</h5>
<div>
<table>
	<tr>
	<th>Directive</th>
	<th>Operands</th>
	<th>Description</th>
	</tr>
	<tr>
	<td>li</td>
	<td>r1, im</td>
	<td>Load a signed immediate value up to 64 bits</td>
	</tr>
	<tr>
	<td>zero</td>
	<td>n</td>
	<td>Fill the next <strong>n</strong> bytes aligned to 32bits with the value 0</td>
	</tr>
	<tr>
	<td>i32</td>
	<td>x</td>
	<td>Store the integer <strong>x</strong> into the next 32 bits</td>
	</tr>
	<tr>
	<td>i64</td>
	<td>x</td>
	<td>Store the integer <strong>x</strong> into the next 64 bits</td>
	</tr>
	<tr>
	<td>f32</td>
	<td>x</td>
	<td>Store the float <strong>x</strong> into the next 32 bits</td>
	</tr>
	<tr>
	<td>f64</td>
	<td>x</td>
	<td>Store the float <strong>x</strong> into the next 64 bits</td>
	</tr>
	<tr>
	<td>str</td>
	<td>s</td>
	<td>Stores the string <strong>s</strong> into the next <em>n</em> bytes, where <em>n</em> is the length of <strong>s</strong> aligned to 32bits</td>
	</tr>
</table>
</div>

POST_FOOTER
