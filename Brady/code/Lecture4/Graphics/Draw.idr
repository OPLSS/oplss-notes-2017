module Graphics.Draw

import public Graphics.SDL
import Control.ST
import Control.ST.ImplicitCall

%default total
%access public export

data Col = MkCol Int Int Int Int

black : Col
black = MkCol 0 0 0 255

red : Col
red = MkCol 255 0 0 255

green : Col
green = MkCol 0 255 0 255

blue : Col
blue = MkCol 0 0 255 255

cyan : Col
cyan = MkCol 0 255 255 255

magenta : Col
magenta = MkCol 255 0 255 255

yellow : Col
yellow = MkCol 255 255 0 255

white : Col
white = MkCol 255 255 255 255

interface Draw (m : Type -> Type) where
  Surface : Type

  initWindow : Int -> Int -> ST m (Maybe Var) [addIfJust Surface]
  closeWindow : (win : Var) -> ST m () [remove win Surface]

  flip : (win : Var) -> ST m () [win ::: Surface]
  poll : ST m (Maybe Event) []

  filledRectangle : (win : Var) -> (Int, Int) -> (Int, Int) -> Col ->
                    ST m () [win ::: Surface]
  drawLine : (win : Var) -> (Int, Int) -> (Int, Int) -> Col ->
             ST m () [win ::: Surface]


Draw IO where
  Surface = State SDLSurface

  initWindow x y = do Just srf <- lift (startSDL x y)
                           | Nothing => pure Nothing
                      var <- new srf
                      pure (Just var)

  closeWindow win = do lift endSDL
                       delete win

  flip win = do srf <- read win
                lift (flipBuffers srf)
  poll = lift pollEvent

  filledRectangle win (x, y) (ex, ey) (MkCol r g b a)
       = do srf <- read win
            lift $ filledRect srf x y ex ey r g b a
  drawLine win (x, y) (ex, ey) (MkCol r g b a)
       = do srf <- read win
            lift $ drawLine srf x y ex ey r g b a
