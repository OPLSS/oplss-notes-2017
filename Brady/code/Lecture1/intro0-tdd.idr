
-- Example 1: Types are first class; compute/manipulate types

StringOrNat : (isStr : Bool) -> Type




-- Example 2: Types of one thing can influence types of another

lengthOrDouble : (isStr : Bool) -> StringOrNat isStr -> Nat










-- Example 3: Formatted output (Type safe printf)

data Format = Number Format
            | Str Format
            | Lit String Format
            | End

%name Format fmt

printfTy : Format -> Type
printfTy (Number f) = (i : Int) -> printfTy f
printfTy (Str f) = (str : String) -> printfTy f
printfTy (Lit str f) = printfTy f
printfTy End = String

printf_aux : (f : Format) -> String -> printfTy f
printf_aux (Number fmt) x = \i => printf_aux fmt (x ++ show i)
printf_aux (Str fmt) x = \str => printf_aux fmt (x ++ str)
printf_aux (Lit y fmt) x = printf_aux fmt (x ++ y)
printf_aux End x = x















------

format' : List Char -> Format
format' [] = End
format' ('%' :: 'd' :: xs) = Number (format' xs)
format' ('%' :: 's' :: xs) = Str (format' xs)
format' ('%' :: xs) = Lit "%" (format' xs)
format' (x :: xs) with (format' xs)
  format' (x :: xs) | (Lit str f) = Lit (strCons x str) f
  format' (x :: xs) | fmt = Lit (strCons x "") fmt

format : String -> Format
format str = format' (unpack str)

printf : (f : String) -> printfTy (format f)
printf f = printf_aux (format f) ""
