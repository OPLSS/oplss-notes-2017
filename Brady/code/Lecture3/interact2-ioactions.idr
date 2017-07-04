hello : IO ()
hello = putStrLn (show (6*6+6))

echo : IO ()
echo = getLine >>= putStrLn

loopy : IO ()
loopy = do putStr "What is your name? "
           name <- getLine
           putStrLn ("Hello " ++ name)
           loopy
