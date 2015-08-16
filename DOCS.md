Docs
====

This is the documentation for strglg.  It will cover all of the available features of it while also giving a small tutorial.

# Functions in strglg

The syntax of strglg is fairly simple to understand.  The basic syntax can be expressed with the usual "Hello, world." program.  Here is the that program in strglg:

```
prn:"Hello, world.\n"
```
**NOTE:** `prn` does not exist yet.

The above example simply takes the string, `"Hello, world.\n"`, and applies `prn` to it.  `prn` takes a string and prints it.  It may not seem so at first, but the `:` does actually have significance.  `:` is an infix operation that applies the left argument to the right argument.  The left argument here is `prn`, and the right is `"Hello, world."`.  Here is an example of addition:

```
+:1 2
```

Like the previous example, `:` applies `+` to the list `1 2`.  This is something important to cover.  It may not look like it, but the `1 2` is a list.  If it helps, visualizing it as `+:(1 2)` might help.  The function, `+`, takes two arguments, which is satisfied by the list of two integers that it was applied to.

These are functions at the most basic level in strglg.  Any function application or literal in strglg is considered an expression.  In the next section, applying functions to the results of other functions will be explained.

# Nesting expressions and right-associativity

The two examples in the previous section are combined here.  Two integers, 1 and 2, will be added together, and the result will be printed using `prn`:

```
prn:(+:1 2)
```

What happens is that `+` is applied to the list, `1 2`, and then `prn` is applied to the sum.  Like in mathematics, the parentheses represent precedence.  However, in this case, the parentheses are unnecessary:

```
prn:+:1 2
```

The example can be written like this.  This brings up an important part of how strglg works.  strglg is *right associative*.  This means that strglg reads everything from right-to-left.  This means that the expression, `+:1 2`, is read first, and then `prn` is applied to that.  This may seem odd at first, but it often times, parentheses can be omitted.

A more complex example to rewrite in strglg would be something like `(1 - 2) * (3 - 4)`.  This can be written as follows:

```
*:(-:1 2) -:3 4
```

Before beginning, the parentheses around the first expression are necessary, as explained in the section after the next.

First, `-:3 4` and `-:1 2` are calculated.  These two differences then act as the arguments for `*`.  This is how nesting expressions works in strglg.

# Lambdas and functions

# Function composition and partial application