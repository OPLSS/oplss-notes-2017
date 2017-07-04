data Access = LoggedOut | LoggedIn
data LoginResult = OK | BadPassword

data Store : (ty : Type) -> Access -> (ty -> Access) -> Type where
     Login : Store LoginResult LoggedOut
                   (\res => case res of
                                 OK => LoggedIn
                                 BadPassword => LoggedOut)
     Logout :     Store ()     LoggedIn (const LoggedOut)
     ReadSecret : Store String LoggedIn (const LoggedIn)

     Pure : (x : ty) -> Store ty (st x) st
     Lift : IO ty -> Store ty st (const st)
     (>>=) : Store a st1 st2 -> ((x : a) -> Store b (st2 x) st3) ->
             Store b st1 st3

exec : Store a st st' -> IO a

getData : Store () LoggedOut (const LoggedOut)
getData = do result <- Login
             case result of
                  OK => do secret <- ReadSecret
                           Lift (putStr ("Secret: " ++ show secret ++ "\n"))
                           Logout
                  BadPassword => Lift (putStr "Failure\n")
