Docs
====

This is the documentation for strglg.  It will cover all of the available features of it while also giving a small tutorial.

## Functions in strglg

The syntax of strglg is fairly simple to understand.  The basic syntax can be expressed with the usual "Hello, world." program.  Here is the that program in strglg:

```
prn:"Hello, world.\n"
```
**NOTE:** `prn` does not exist yet.

The above example simply takes the string, `"Hello, world.\n"`, and applies `prn` to it.  `prn` takes a string and prints it.  It may not seem so at first, but the `:` does actually have significance.  `:` is an infix operator that applies the left argument to the right argument.  The left argument here is `prn`, and the right is `"Hello, world."`.  Here is an example of addition:

```
+:1 2
```

Like the previous example, `:` applies `+` to the list `1 2`.  This is something important to cover.  It may not look like it, but the `1 2` is a list.  If it helps, visualizing it as `+:(1 2)` might help.  The function, `+`, takes two arguments, which is satisfied by the list of two integers that it was applied to.

These are functions at the most basic level in strglg.  Any function application or literal in strglg is considered an expression.  In the next section, applying functions to the results of other functions will be explained.

## Nesting expressions and right-associativity

The two examples in the previous section are combined here.  Two integers, 1 and 2, will be added together, and the result will be printed using `prn`:

```
prn:(+:1 2)
```

What happens is that `+` is applied to the list, `1 2`, and then `prn` is applied to the sum.  Like in mathematics, the parentheses represent precedence.  However, in this case, the parentheses are unnecessary:

```
prn:+:1 2
```

The example can be written like this.  This brings up an important part of how strglg works.  strglg is *right associative*.  This means that strglg reads everything from right-to-left.  This means that the expression, `+:1 2`, is read first, and then `prn` is applied to that.  This may seem odd at first, but often times, parentheses can be omitted.

A more complex example to rewrite in strglg would be something like `(1 - 2) * (3 - 4)`.  This can be written as follows:

```
*:(-:1 2) -:3 4
```

Before beginning, the parentheses around the first expression are necessary, as explained in the section after the next.

First, `-:3 4` and `-:1 2` are calculated.  These two differences then act as the arguments for `*`.  This is how nesting expressions works in strglg.

## Lambdas

Lambdas are essentially synonymous with the concept of "anonymous function".  They are functions in that they take an amount of arguments and return something, but they have no name.  This also means that functions (at least in strglg) are just named lambdas (this is also true in languages like LISP).

Here is a lambda that takes one argument and returns the argument incremented by 1:

```
la:($:a) +:1 a
```

Their are multiple new concepts in this expression.  First, `la` is its own function that takes two arguments: a list of parameters and the body of the lambda.  The parameters are a set of arguments that the lambda requires.  The body is any expression that makes use of these arguments.  

Notice that the argument is used in the `+` expression.  Anything that is not a literal (that is, anything that isn't a string, char, number, function, or lambda), is read as a symbol.  Symbols don't have a set type, and because of this, they are accepted by all functions.  

Lastly is the `$` function.  This function creates a list out of the rest of the arguments (think `list` in LISP).  Like its LISP counterpart, the amount of arguments that `$` takes is not set.  Instead, it takes all arguments given to it.

What is returned is the lambda, `([a] -> +:1 a)`, taking one argument, and returning that argument + 1.  Note the fact that it *return*ed a function.  Like any other functional language, strglg's functions and lambdas are first-class.  This means that they can be used as if they were literals; they can be used as arguments to other functions and be returned.

Using `:`, a lambda can be applied to arguments just like any other function:

```
(la:($:a) +:1 a):2
```

(Note the necessity of parentheses around the lambda.  Without them, the first expression read would be `a:2`, which is not valid.)

## Functions

Functions, as mentioned before, are just named lambdas.  They are fairly easy to define:

```
def:inc la:($:a) +:1 a
```

Here, the example shown in the previous section is used as the subject for a new function.    `def` is a function that takes 2 arguments: the name and a lambda that represents the body.  This is also an example of lambdas being first-class, as here, one is being used as an argument for `def`.

After the definition, the new function works as it should:

```
inc:2
```

This is the same as the example in the previous section.

## Function composition

Now that lambdas have been explained, it is time to get into the main part of the language.

There are two major parts of concatenative languages that separate them from others:
* Everything is a function.  Even literals are just functions that take no arguments and return new values.
* Concatenative languages work off of function composition.

strglg, while not strictly concatenative itself, borrows some of these ideas.  Function composition in programming is very similar to that of in mathematics.  Consider the following definition that works just like addition, but increments the first argument:

```
def:(+inc la:($:a b) +:(inc:a) b)
```

However, there is another way this definition could be written:

```
def:(+inc la:($:a b) (+ inc):a b)
```

This is the same as the previous definition, only that here, a new function was composed of `inc` and `+`.  To better understand composition, take these two expressions:

```
f(g(x))
(f∘g)(x)
```

These expressions are the exact same.  It should be noticed that in the second statement, the arguments are isolated.  The difference between the two expressions is that the first one is a function applied to another function applied to the argument, `x`, while the second is simply a function (which happens to be composed of two other functions) applied to the argument, `x`.  This is something very important (especially for the next section).

The expression, `(+ inc):a b`, works the same way.  For now, `+ inc` will be the only focus.  First thing to explain the syntax of function composition in strglg.  Earlier, it was discussed that `:` was an infix operator for function application.  There is one other "infix operator" that exists in strglg, and this operator is for function composition.  However, unlike in math where this operator is `∘`, there is no real operator in strglg.  Instead, the lack of any operator (whitespace, essentially) represents composition.

Using this syntax, `+ inc` is the composition of `+` and `inc`, since there was no infix operator.  Before beginning, recall that everything is right-associative, so function composition happens in reverse order, like it does in math.  Here are the lambda representation of both functions:

```
([a0] -> inc:a0)
([a0 a1] -> +:a0 a1)
```
**NOTE:** any non-user created lambda names its arguments from a0..a*N*.

This clearly shows the amount of arguments taken by both functions.  Note that both lambdas have `a0` as an argument, and that `a0` is the only argument needed for `inc`.  Because of this, `inc` can be "absorbed" into the second lambda when composed:

```
([a0 a1] -> +:(inc:a0) a1)
```

Above is the resulting composed function.  Notice that it is the exact same as the regular definition of `+inc`.

The other thing that needs to be discussed is how literals are parsed.  Recall the expression, `+:1 2`.  With what is known now, it should be noticed that the list `1 2` is actually function composition.  For this example, the expression will be changed to `+ 1 2`; here are the lambdas for each value:

```
([] -> 2)
([] -> 1)
([a0 a1] -> +:a0 a1)
```

Like other concatenative languages, literals are functions that take no arguments and return the literal.  When composed, it just works as if one is appended to the other: `([] -> 1 2)`.  This is then composed with the final lambda, which is `([] -> +:1 2)`.  Something to note is that since the `:` was removed, instead of returning the result, the fully composed lambda is returned.

Finally, consider the composition `+ -`:

```
([a0 a1] -> -:a0 a1)
([a0 a1] -> +:a0 a1)
```

Here is the following result of composition:

```
([a0 a1 a2] -> +:(-:a0 a1) a2)
```

The result would require three arguments to work: two for `-`, and a third one to add to the difference.  Essentially, the first function becomes the first argument for the second function.

## Partial application and currying

This is where the usefulness of function composition can appear.  Every single lambda written so far was not really necessary to write.  Instead, functions can be composed to create partially implied functions.  Take the increment function from earlier:

```
la:($:a) +:1 a
```

The same definition can simply be rewritten as:

```
+ 1
```

As talked about in the last section, what is done here is function composition.  The result of the lambda is as follows:

```
([a0] -> +:1 a0)
```

This represents the same lambda as defined earlier.  However, using composition, there was no need to actually mention the names of the arguments.  This is essentially the idea of point-free programming.  That is, arguments are not explicitly mentioned, rather they are implicit.

The new definition can easily be applied like anything else:

```
(+ 1):2
```

In this case, the point-free definition of increment is arguably more readable than the regular lambda based definition.  Of course, point-free notation is not always the best and most readable solution to a problem, and in that case, a lambda should probably be used instead.

Another way to see partial application is through currying.  Currying is a process that transforms any multi-argument function into a single-argument function that returns a lambda for the next argument, and if there are more argumnets, then that lambda returns another lambda, and so on depending on how many arguments the original function has.

Consider the function, `+`.  Here is the curried version of `+`:

```
la:($:a) la:($:b) +:a b
```

With this definition, the expression, `+ 1` becomes entirely valid.  What is returned is the lambda, `la:($:b) +:1 b`.  Because of this, partial application is entirely possible.

Before ending this section, it is important to note that partial application is not allowed when using `:`.  That is, the expression, `+:1`, will return an error.  Unless the amount of arguments is undetermined, the arguments must equal the amount needed when using `:`.

## Stopping unnecessary composition

Sometimes, it can be undesirable for composition to automatically happen.  Take this example:

```
map:(+ 1) $:1 2 3
```

`map` is a function that takes two arguments.  The first argument must be a lambda that takes one argument while the second is any list.  The lambda is applied to every element in the list, returning a new list containing the results.  For example, the resulting list here would be `2 3 4`.  However, there is a problem.  As it is, the lambda, `+ 1` is actually composed with `$:1 2 3`, making `+ 1 $:1 2 3`.  The compiler will return an error saying that only one argument was passed.

What is wanted instead, is a lambda that ignores forced composition.  This is what the apostrophe, `'`, is for.  Here is the correct expression:

```
map:'(+ 1) $:1 2 3
```

Instead of being composed, the lambda stays as is.  Here, `map` is correctly applied to the correct arguments.  Essentially, `'` takes whatever lambda associated with it and blocks it from being composed with anything.

## Recursion and signatures

Side-topics
====

This section has documentation describes some other topics in strglg.

## Lambda producing functions

These functions use their arguments to produce a lambda 

### Forks

**NOTE:** forks have not been added yet.

The symbol for the fork function is `#`.

```
sig: # $:?
```

`#` takes any amount of lambdas as arguments and returns a new lambda returning a list of the applications of each lambda on different arguments.  Consider the example, `list (x - y) (x + y)`.  This is easy to define in strglg:

```
def:-+ (-:x y) +:x y
```

This example, however, can be written in a different way using forks:

```
def:-+ (#:'+ -):x y
```

(this definition can also be written point-free: `def:-+ #:'+ -`

Here, `#` takes its arguments and produces the lambda: `([x y] -> list (-:x y) (+:x y))`.  What happens is that a lambda is produced returning a list of each function listed applied to the same arguments.  This helps creating branches that require the same values without needing to define a local variable.

Lastly, it should be noted that `#` requires that all arguments have the same amount of input values.

# Status

This documentation is not finished.  It is also not necessarily well written, and it may be better to look up alternate explanations for some concepts.