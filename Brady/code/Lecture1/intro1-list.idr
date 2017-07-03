{- Definition from the Prelude:

infixr 5 ::

data List a = Nil | (::) a (List a)
-}

my_append : List a -> List a -> List a

my_map : (a -> b) -> List a -> List b

my_zipWith : (a -> b -> c) -> List a -> List b -> List c
