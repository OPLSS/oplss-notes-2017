module Conc

import Control.ST
import Control.ST.ImplicitCall
import System.Concurrency.Channels

%default covering

%access public export

namespace Protocol
  data Protocol : Type -> Type where
       (>>=) : Protocol a -> (a -> Protocol b) -> Protocol b
       Done : Protocol ()

       Request : (ty : Type) -> Protocol ty
       Serve : (ty : Type) -> Protocol ty

data Actions : Type where
     Send : (a : Type) -> (a -> Actions) -> Actions
     Recv : (a : Type) -> (a -> Actions) -> Actions
     Done : Actions

asClient : Protocol a -> (a -> Actions) -> Actions
asClient (p >>= rest) k = asClient p (\ty => asClient (rest ty) k)
asClient Done k = k ()
asClient (Request a) k = Send a k
asClient (Serve a) k = Recv a k

asServer : Protocol a -> (a -> Actions) -> Actions
asServer (p >>= rest) k = asServer p (\ty => asServer (rest ty) k)
asServer Done k = k ()
asServer (Request a) k = Recv a k
asServer (Serve a) k = Send a k

client : Protocol () -> Actions
client proto = asClient proto (\ty => Done)

server : Protocol () -> Actions
server proto = asServer proto (\ty => Done)

data ServerState = Ready | Processed

interface Conc (m : Type -> Type) where
  data Channel : Actions -> Type
  data Server : Protocol () -> Type
  Accepting : ServerState -> Protocol () -> Type

  -- Fork a child thread. Share current resources (all) between child
  -- thread (thread_res) and parent thread (kept tprf).
  -- The child thread has a channel with the 'child' protocol, and the parent
  -- thread has its dual
  fork : (thread : (chan : Var) ->
                   STrans m () ((chan ::: Channel (server proto)) :: thread_res)
                               (const [])) ->
         {auto tprf : SubRes thread_res all} ->
         STrans m Var all (\chan =>
                          ((chan ::: Channel (client proto)) :: kept tprf))

  -- Start a server running, ready to accept connections to create a channel
  -- which runs 'proto'. We don't provide a way to delete 'Accepting', so
  -- this has to run forever... (or crash...)
  -- Returns a reference to the server which we can connect to as many
  -- times as we like.
  -- (TODO: Make this work as a total, productive function)
  start : (server : (acc : Var) ->
             STrans m () ((acc ::: Accepting Ready proto) :: thread_res)
                 (const ((acc ::: Accepting Processed proto) :: thread_res))) ->
          {auto tprf : SubRes thread_res all} ->
          STrans m (Server proto) all (const (kept tprf))

  -- Listen for a connection on acc, making a new channel
  listen : (acc : Var) -> (timeout : Int) ->
           ST m (Maybe Var) [acc ::: Accepting Ready proto :->
                                     Accepting Processed proto,
                             addIfJust (Channel (server proto))]
  -- Connect to a server and make a new channel for talking to it with
  -- the appropriate protocol
  connect : Server proto -> ST m Var [add (Channel (client proto))]

  -- Can only 'send' if the channel is ready to send a ty
  send : (chan : Var) -> (val : ty) ->
         ST m () [chan ::: Channel (Send ty f) :-> Channel (f val)]
  -- Can only 'recv' if the channel is ready to receive a ty
  recv : (chan : Var) ->
         ST m ty [chan ::: Channel (Recv ty f) :-> (\res => Channel (f res))]

  -- Can only 'close' when a protocol is Done
  close : (chan : Var) -> ST m () [Remove chan (Channel Done)]

ChildProc : Var -> (m : Type -> Type) -> Conc m => Protocol () -> Action ()
ChildProc chan m proto = Remove chan (Channel {m} (server proto))

ServerProc : Var -> (m : Type -> Type) -> Conc m => Protocol () -> Action ()
ServerProc chan m proto = chan ::: Accepting {m} Ready proto :->
                                   Accepting {m} Processed proto


-- %hint
-- inStateEnd : InState lbl st (xs ++ [lbl ::: st])
-- inStateEnd {xs = []} = Here
-- inStateEnd {xs = (x :: xs)} = There inStateEnd

-- To run our programs, we need to implement the 'Conc' interface under IO
-- This is really hacky and involves lots of unsafe primitives. Fortunately,
-- we only have to get this right once... but we do have to get it right.

-- So. Move along. Nothing to see here :).

-- If any of the believe_mes in here get executed, we have a disastrous
-- failure caused by being out of memory (or other similar problem).
-- Nevertheless, TODO: clean them up. (It can be done with proper error
-- handling)
Conc IO where
  Channel x = State Channels.Channel
  Server x = PID
  Accepting _ _ = ()

  fork thread {tprf} = do
         threadEnv <- dropSub {prf=tprf}
          -- Need to create a dummy resource to feed to the new
          -- thread, to stand for the 'Channel' variable which
          -- we'll create a proper value for when we spawn.
         dummy <- new ()
         Just pid <- lift $ spawn (do Just chan <- listen 1
                                           | Nothing => believe_me ()
                                      runWith (Value chan :: threadEnv)
                                              (thread dummy)
                                      pure ())
              | Nothing => believe_me () -- Disastrous failure...
         delete dummy
         Just ch <- lift $ connect pid
              | Nothing => believe_me () -- Disastrous failure...
         new ch

  start server {thread_res} {tprf} = do
         threadEnv <- dropSub {prf=tprf}
         -- Need to create a dummy resource to feed to the new
         -- thread, to stand for the 'Accepting' resource which
         -- is only there to say what kind of protocols it will
         -- work with
         dummy <- new ()
         Just pid <- lift $ spawn (do runWithLoop
                                          (() :: threadEnv)
                                          forever
                                          (serverLoop server dummy)
                                      pure ())
             | Nothing => believe_me () -- Disastrous failure...
         delete dummy
         pure pid
    where serverLoop : ((acc : Var) ->
             STrans IO () ((acc ::: ()) :: thread_res)
                   (const ((acc ::: ()) :: thread_res))) ->
             (acc : Var) -> STransLoop IO () ((acc ::: ()) :: thread_res)
                                      (const ((acc ::: ()) :: thread_res))
          serverLoop f acc = do f acc
                                serverLoop f acc

  listen acc timeout = do Just ch <- lift $ listen timeout
                               | Nothing => pure Nothing
                          chvar <- new ch
                          toEnd chvar
                          pure (Just chvar)
  connect pid = do Just ch <- lift $ connect pid
                        | Nothing => believe_me () -- Disastrous failure...
                   new ch
  send chan val = do ch <- read chan
                     lift $ unsafeSend ch val
                     pure ()
  recv {ty} chan = do ch <- read chan
                      Just val <- lift $ unsafeRecv ty ch
                           | Nothing => believe_me () -- Can't happen!
                      pure val
  close chan = delete chan
