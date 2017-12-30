This is an instructional project from 'Low-Level Programming' by Igor Zhirkov

https://www.apress.com/us/book/9781484224021

I recommend this book and doing this project if you're interested in learning
some x86 assembly, upping your GDB game, and just generally having a better
idea what's going to turn your high-level code into a linkable/executable unit.
I screwed up a lot of silly things with syntax, almost entirely related moving
data the way I intended versus the way I'd written. After the pain of debugging
that stuff I want to avoid writing assembly wherever I can. Gimme back my high-level
language and mature compiler!

The source is for a Forth interpreter/compiler that reads Forth programs from
stdin and executes them. The dialect is some subset of Forth, I didn't dig into
that too much. You'll need NASM, make, and ld to build. You should be able to
just run 'make' once you have all the requirements. Read the test files and source
to see what Forth words have been implemented.
