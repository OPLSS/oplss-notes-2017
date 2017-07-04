import Control.ST
import Control.ST.ImplicitCall

swap : (comp : Var) -> ST m () [comp ::: Composite [State Int, State Int]]
swap comp = do [val1, val2] <- split comp
               combine comp [val2, val1]

