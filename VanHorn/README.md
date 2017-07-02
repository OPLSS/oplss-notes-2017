# Redex, Abstract Machines, and Abstract Interpretation -- Van Horn

**Instructor:** Dr. David Van Horn  (University of Maryland)	


Code and pointers from today
Here is the code I presented in today's lecture.  The sam.rkt file contains the complete development I wrote during Sam's lecture.  sam0.rkt is the stuff we wrote together.  The sam-help.rkt file contains helper functions.  You should be able to download them all to the same directory and run it.
 
sam.rkt
sam0.rkt
samhelp.rkt
 
At the end of the lecture, it was noted that I missed the reduction rule:
 
E[(error l)] --> (error l)
 
See if you can modify the semantics and confirm it works on the example.
 
The talk by Robby Finder I mentioned is here:
https://www.youtube.com/watch?v=BuCRToctmw0
 
In additional to my tutorial (https://dvanhorn.github.io/redex-aam-tutorial/), there is also a good tutorial in the Racket documentation:
http://docs.racket-lang.org/redex/redex2015.html
