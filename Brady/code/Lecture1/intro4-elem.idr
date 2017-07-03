data Elem : a -> List a -> Type where
     Here : Elem x (x :: xs)
     There : Elem x ys -> Elem x (y :: ys)

Beatles : List String
Beatles = ["John", "Paul", "George", "Ringo"]

georgeInBeatles : Elem "George" Beatles



peteNotInBeatles : Not (Elem "Pete" Beatles)



isElem : (x : a) -> (xs : List a) -> Maybe (Elem x xs)
