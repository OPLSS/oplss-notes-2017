{- Productivity: streams -}

{- Stream is defined in the Prelude:

data Stream : Type -> Type where
  (::) : (value : elem) -> Inf (Stream elem) -> Stream elem

-}

countFrom : Nat -> Stream Nat

firstn : Nat -> Stream Nat -> List Nat
