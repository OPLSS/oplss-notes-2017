import Data.Vect

data EqNat : Nat -> Nat -> Type where
     SameNat : (num : Nat) -> EqNat num num

smallProofEq : EqNat (2 + 2) 4


successorEq : EqNat x y -> EqNat (S x) (S y)

{- Built in equality type:

data (=) : a -> b -> Type where
     Refl : x = x

-}

smallProof : 2 + 2 = 4


notTrue : 2 + 2 = 5 -> Void


{- Equality in action! -}

tryZip : Vect n a -> Vect m b -> Maybe (Vect n (a, b))


myReverse : Vect n a -> Vect n a
