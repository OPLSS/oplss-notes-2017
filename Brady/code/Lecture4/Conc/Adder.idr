import Conc

import Control.ST
import Control.ST.ImplicitCall

data Cmd = Add Nat Nat

Adder : Protocol ()
Adder = do cmd <- Request Cmd
           case cmd of
                Add x y => do Serve Nat
                              Done

addServer : (ConsoleIO m, Conc m) =>
            (server : Var) ->
            ST m () [ServerProc server m Adder]
addServer server = do
        Just chan <- listen server 5
             | Nothing => putStrLn "Nothing received"
        cmd <- recv chan
        case cmd of
             Add k j => do send chan (k + j)
                           close chan

-- Connect to a server which is using the 'AddServer' protocol and ask
-- it to add things
callAdder : (ConsoleIO m, Conc m) =>
            Server {m} Adder -> ST m () []
callAdder server = do
        putStr "Enter a number: "
        num <- getStr
        chan <- connect server
        send chan (Add (cast num) 100)
        ans <- recv chan
        close chan
        putStrLn ("Result: " ++ show ans)

-- Start up an addition server, and ask it a couple of questions
runUtilServer : (ConsoleIO m, Conc m) => ST m () []
runUtilServer = do
     putStr "Starting server\n"
     serverID <- start addServer
     callAdder serverID

-- Finally, run the thing
main : IO ()
main = run runUtilServer
