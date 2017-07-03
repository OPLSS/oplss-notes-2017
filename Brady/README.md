# Dependent Types in the Idris Programming Language -- Brady

**Instructor:** Edwin Brady (University of St Andrews)


## Hands-on Idris
(The following is a copy of a Piazza post by Edwin Brady.)

Hi folks,
If you're looking for some Idris hacking to do in the hands-on session later, I suggest the following:
 
1. If you haven't yet completed the code samples (see   
   https://www.idris-lang.org/documentation/workshops/oplss-2017-course-materials/), make sure you can get those working
 
2. Today we worked though checkEqNat, to build a proof of equality of 
   two natural numbers, if possible. Try to implement similar functions for List and Vect
 
   (Hint: You'll probably need to use the decEq function to check equality of the elements of each structure)
 
3. Try to implement myReverse, from total1-eq.idr. This involves the
   rewrite construct, which I haven't covered yet, but essentially it works as follows:
 
   Say you have an expression p of type x=y, and a hole ?foo of type Prf x, then in the expression rewrite p in ?foo, the type of the hole ?foo becomes Prf y
 
In the next lecture, I'll say a bit about working with streams, then move on to implementing DSLs with state. I'll show how to use the type system to guarantee correct state transitions in a bank's ATM - this is a much more involved example than we've seen so far, but it'll put into practice many of the type system features we've seen over the last couple of days.


----------

## Miscellaneous Notes

### Some Idris keybindings (interactive editing commands)

These work in the Atom editor, and probably in other editors as well.

| Shortcut | Command | Description |
| -------- | ------- | ----------- |
| `Ctrl-Alt-A` | Add definition | Adds a skeleton definition for the name under the cursor |
| `Ctrl-Alt-C` | Case split | Splits a definition into pattern-matching clauses for the name under the cursor |
| `Ctrl-Alt-D` | Documentation | Displays documentation for the name under the cursor |
| `Ctrl-Alt-L` | Lift hole | Lifts a hole to the top level as a new function declaration |
| `Ctrl-Alt-M` | Match | Replaces a hole with a case expression that matches on an intermediate result |
| `Ctrl-Alt-R` | Reload | Reloads and type-checks the current buffer |
| `Ctrl-Alt-S` | Search | Searches for an expression that satisfies the type of the hole name under the cursor |
| `Ctrl-Alt-T` | Type-check name | Displays the type of the name under the cursor |


### REPL Commands

The Idris read-eval-print loop (REPL) provides several commands.
The most common are listed here.

| Command | Arguments | Description |
| ------- | --------- | ----------- |
| `<expression>` | None | Displays the result of evaluating the expression. The variable `it` contains the result of the most recent evaluation. |
| `:t` | `<expression>` |  Displays the type of the expression. |
| `:total` | `<name>` | Displays whether the function with the given name is total. |
| `:doc` | `<name>` | Displays documentation for name. |
| `:let` | `<definition>` | Adds a new definition. |
| `:exec` | `<expression>` | Compiles and executes the expression. If none is given, compiles and executes main.|
| `:c` | `<output file>` | Compiles to an executable with the entry point main. |
| `:r` | `None ` | Reloads the current module. |
| `:l` | `<filename>` | Loads a new file. |
| `:module` | `<module name>` | Imports an extra module for use at the REPL. |
| `:printdef` | `<name>` | Displays the definition of name. |
| `:apropos` | `<word>` | Searches function names, types, and documentation for the given word.|
| `:search` | `<type>` | Searches for functions with the given type. |
| `:browse` | `<namespace>` | Displays the names and types defined in the given namespace.|
| `:q` | `None ` |Exits the REPL. |

