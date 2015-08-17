strglg
====

# What is strglg?

*strglg* is a language based off of concepts from point-free and concatenative languages.  As the name might imply, string operations are one of the main points of the language.  Function composition and partial application are two of the main concepts.

# How does the compiler work?

The strglg compiler is built in Racket, and also compiles to Racket.  **I might also make it possible to compile to LLVM-IR at some point.**

# What influenced strglg?

As mentioned before, strglg is influenced by point-free and concatenative languages.  The syntax somewhat resembles FP.  Factor, and other concatenative languages, are influences for how function composition works in strglg.  Similarly, Haskell was also an influence because of how its own system of composition, currying, and point-free programming work.

To a lesser extent, LISP is also an influence.

# Documentation

There is a simple set of documentation in DOCS.md.

# Status

This is just a small project I'm working on.  There aren't any plans to make this into much more than a for-fun project.