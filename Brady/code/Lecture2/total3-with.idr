listTail : List a -> Maybe (List a)



listInit : List a -> Maybe (List a)





data SnocList : List a -> Type where
     Empty : SnocList []
     Snoc : (rec : SnocList xs) -> SnocList (xs ++ [x])

snocList : (xs : List a) -> SnocList xs

myReverse : List a -> List a





{-

data ListLast : List a -> Type where
     LEmpty : ListLast []
     LNonEmpty : (xs : List a) -> (x : a) -> ListLast (xs ++ [x])

listLast : (xs : List a) -> ListLast xs

listInitHelp : (xs : List a) -> ListLast xs -> Maybe (List a)
listInitHelp [] LEmpty = Nothing
listInitHelp (ys ++ [x]) (LNonEmpty ys x) = Just ys

-}

{-
snocListHelp : (snoc : SnocList input) ->
               (rest : List a) -> SnocList (input ++ rest)
snocListHelp {input} snoc []
    = rewrite appendNilRightNeutral input in snoc
snocListHelp {input} snoc (x :: xs)
    = rewrite appendAssociative input [x] xs in
              snocListHelp (Snoc snoc) xs

snocList : (xs : List a) -> SnocList xs
snocList xs = snocListHelp Empty xs
-}
