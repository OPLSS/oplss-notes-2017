import Control.ST

data Access = LoggedOut | LoggedIn
data LoginResult = OK | BadPassword

interface DataStore (m : Type -> Type) where
  Store : Access -> Type

  connect : STrans m Var [] (\store => [store ::: Store LoggedOut])
  disconnect : (store : Var) ->
               STrans m () [store ::: Store LoggedOut] (const [])
  login : (store : Var) ->
          STrans m LoginResult
                   [store ::: Store LoggedOut]
          (\res => [store ::: Store (case res of
                                          OK => LoggedIn
                                          BadPassword => LoggedOut)])
  logout : (store : Var) ->
           STrans m () [store ::: Store LoggedIn]
                (const [store ::: Store LoggedOut])
  readSecret : (store : Var) ->
               STrans m String [store ::: Store LoggedIn]
                        (const [store ::: Store LoggedIn])

getData : (ConsoleIO m, DataStore m) => STrans m () [] (const [])
getData = do st <- connect
             result <- login st
             case result of
                  OK => do secret <- readSecret st
                           putStr ("Secret: " ++ show secret ++ "\n")
                           logout st
                           disconnect st
                  BadPassword => do putStr "Failure\n"
                                    disconnect st

DataStore IO where
  Store x = State String -- represents secret data

  connect = do store <- new "Secret Data"
               pure store

  disconnect store = delete store

  login store = do lift (putStr "Enter password: ")
                   p <- lift getLine
                   if p == "Mornington Crescent"
                      then pure OK
                      else pure BadPassword
  logout store = pure ()

  readSecret store = do secret <- read store
                        pure secret

main : IO ()
main = run getData
