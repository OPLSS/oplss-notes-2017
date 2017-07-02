In case things go well today, I will talk about and program in Concurrent C0 tomorrow.  If you are interested, below are the download instructions. I will explain the mapping from SILL to Concurrent C0 tomorrow, before lecture, so it may be best to wait before you start hacking.  The intrepid can look at some of the examples.
To obtain the sources of Concurrent C0, do
svn checkout https://svn.concert.cs.cmu.edu/c0
with userid c0guest, password c0c0ffee.  You will need an implementation of Standard ML (either mlton or sml/nj) plus a standard C compiler like gcc or clang.  To use the (limited) Go back end, you'll also need go, of course.
Look in cc0-concur/README-concur.txt for build and testing instructions.  You can find examples in
tests/concur/*.c1
tests/sharing/*.c1
bench/*.c1
For background information on C0, see http://c0.typesafety.net
There also links to materials for the "Principles of Imperative Computation" course that uses C0.
