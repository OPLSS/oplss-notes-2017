


## Hands-on Idris
(A Piazza post by Edwin Brady)

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
