%default total

data Command : Type -> Type where
     PutStr : String -> Command ()
     GetStr : Command String

%name Command cmd

data InfIO : Type where
     Do : Command a -> (a -> Inf InfIO) -> InfIO

(>>=) : Command a -> (a -> Inf InfIO) -> InfIO
(>>=) = Do

loopy : InfIO
loopy = do PutStr "What is your name? "
           name <- GetStr
           PutStr ("Hello " ++ name ++ "\n")
           loopy

{- Running interactive programs -}

run : InfIO -> IO ()


{- Define a way of saying when an interactive program terminates -}

data Fuel = Dry | More (Lazy Fuel)

tank : Nat -> Fuel
tank Z = Dry
tank (S k) = More (tank k)

run_total : Fuel -> InfIO -> IO ()
