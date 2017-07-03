Lecture 1
---------

#### Why would one use Idris over Haskell, other than to get more help from the compiler?
#### What is the most important feature missing from Idris?
#### Are there plans to rewrite Idris in Idris?
#### Have dependent types ever helped you catch a serious bug?
#### Are there any rules about names, or is it just a convention to use lower case for function names and upper case initial letters for type names?
#### Why do you have a PHP backend?
#### Is there a standard library and can I contribute?
#### Is there anything fundamental about a dependently typed language that makes it slower at run time?
#### Why is Idris called Idris?
#### What books would you recommend before reading "Type Driven Development with Idris"?
#### In the interactive editor mode, why does lifting a function out include all the variables?
#### What are some "nuts and bolts" datatypes that are particularly useful?
#### Is there anything that Type Driven Development is *not* good for?
#### Would there be any benefits to generating Coq or Agda from Idris code?
#### What kinds of properties are worth encoding in the type system?
#### Are there ways to get the program inference and interactivity oustide the editor, say at the REPL?
#### How does Idris deal with non-termination?
#### Would it be possible to add more constraints on holes, e.g. that the result shoudl satisfy a certain property?

Lecture 2
---------

#### Can you say more about how erasure works?
#### Where can I get a t-shirt that says "It type checks! Ship it!"
#### How quickly do improvements to Idris get incorporated into the released version?
#### Are there any uses of Idris in industry? Is it ready?
#### What are some examples that illustrate where it is useful for `(=)` to take two different types?
#### What limitations does totality impose for practical programming?
#### Is `impossible` a type? If so how is it defined?
#### Can case branches be `impossible`?
#### Why do I need to give `impossible` cases at all? Can't the machine infer them?
#### Is it possible to write partial functions and prove totality later?
#### How does Idris deal with Universes? (That is, what is the type of `Type`?)
#### Does Idris have a "core" language like Haskell does?
#### Has anyone written a web application in Idris?
#### Can I make some decidable checks dynamically?
#### Does Idris have an equivalent of Agda's dot patterns?
#### Is it too late for an ML style module system for Idris?
#### How do you "test" types?
#### Does Idris assume function extensionality?
#### Is there a connection between `Dec` and the Law of the Excluded Middle?
#### How can I learn about how Idris is implemented?

Lecture 3
---------

#### What's your favourite undocumented feature of Idris?
#### Could "covering" or "total" be default rather than "partial"?
#### Where can we learn more about theorem proving in Idris?
#### Can we do property based testing in Idris?
#### Is it possible to extract to Haskell?
#### Could you parameterise a type by whether it is infinite/lazy or not?
#### What is the hardest/most annoying thing about implementing something like Idris?
#### How do I use `.ipkg` files in Atom?
#### When is the `case` in the type of `Open` evaluated?
#### Is there documentation on pattern matching alternatives in do notation?  I want this in Haskell
#### Could type-driven development work in a mainstream language like Java?
#### Why are constructors scoped to the module and not the datatype?
#### Is this idea of putting states in types related to Session Types?
#### Is there a relationship between Prolog and dependent types and could you express state machines this way in Prolog?
#### Can we do implicits like Force and Delay for other types?
#### Do we have extensionality in Idris?
#### How do you prove equivalence of functions? e.g. if you have `f : a -> b` and `g : a -> b` could it be possible to prove `f = g`
#### Does the concrete representation of IO obey the monad laws?
