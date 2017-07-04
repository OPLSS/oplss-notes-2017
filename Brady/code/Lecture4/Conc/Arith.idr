import Conc

import Control.ST
import Control.ST.ImplicitCall

data Cmd = Add Nat Nat
         | Append String String

Utils : Protocol ()
Utils = do cmd <- Request Cmd
           case cmd of
                Add x y => do Serve Nat
                              Done
                Append x y => do Serve String
                                 Done

arithServer : (ConsoleIO m, Conc m) =>
              (counter : Var) ->
              (server : Var) ->
              ST m () [ServerProc server m Utils,
                       counter ::: State Int]
arithServer counter server = do
        Just chan <- listen server 1
             | Nothing => pure ()
        val <- read counter
        putStr $ "Request number " ++ show val ++ "\n"
        write counter (val + 1)
        cmd <- recv chan
        case cmd of
             Add k j => do send chan (k + j)
                           close chan
             Append x y => do send chan (x ++ y)
                              close chan

-- Connect to a server which is using the 'AddServer' protocol and ask
-- it to add things
callUtils : (ConsoleIO m, Conc m) =>
            Server {m} Utils -> Nat -> Nat -> ST m () []
callUtils server x y = do
        chan <- connect server
        send chan (Add x y)
        ans <- recv chan
        close chan
        chan <- connect server
        send chan (Append "Result: " (show ans))
        display <- recv chan
        close chan
        putStrLn display

-- Start up an addition server, and ask it a couple of questions
runUtilServer : (ConsoleIO m, Conc m) => ST m () []
runUtilServer = with ST do
     putStr "Starting server\n"
     counter <- new 0
     serverID <- start (arithServer counter)
     callUtils serverID 20 22
     callUtils serverID 40 54

-- Finally, run the thing
main : IO ()
main = run runUtilServer
