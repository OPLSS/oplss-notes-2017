%default total

data InfIO : Type where
     Do : IO a -> (a -> Inf InfIO) -> InfIO

(>>=) : IO a -> (a -> Inf InfIO) -> InfIO
(>>=) = Do

loopy : InfIO
loopy = do putStr "What is your name? "
           name <- getLine
           putStrLn ("Hello " ++ name)
           loopy

{- Running interactive programs -}

run : InfIO -> IO ()

{- Define a way of saying when an interactive program terminates -}

data Fuel = Dry | More (Lazy Fuel)

tank : Nat -> Fuel
tank Z = Dry
tank (S k) = More (tank k)

run_total : Fuel -> InfIO -> IO ()
