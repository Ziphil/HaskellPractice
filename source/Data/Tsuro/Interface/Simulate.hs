{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}


module Data.Tsuro.Interface.Simulate where

import Data.Tsuro
import Data.Tsuro.Interface.Util
import Data.Tsuro.Search.Core
import qualified Data.Tsuro.Search.Montecarlo as Montecarlo
import Data.Tsuro.Show


data SomeSearch = forall s. Search IO s => SomeSearch s

start :: IO ()
start = do
  SomeSearch search <- inputSearch
  ((game, record), status) <- simulate search
  flushStrLn ""
  flushStrLn $ showRich game
  case status of
    Success -> do
      flushStrLn $ colorMessage "@ Succeeded."
      flushStrLn $ colorMessage $ "@ Record: " ++ showRich record
    Failure -> do
      flushStrLn $ colorMessage "@ Failed."
      flushStrLn $ colorMessage $ "@ Record: " ++ showRich record ++ " " ++ either (const "") (show . number) (nextHand game) ++ "*"

inputSearch :: IO SomeSearch
inputSearch = do
  flushStr $ colorInput "<?> Algorithm -> "
  input <- getLine
  case input of
    "m" -> return $ SomeSearch Montecarlo.defaultConfig
    "mf" -> return $ SomeSearch (Montecarlo.Config 1000 4 3)
    _ -> do
      flushStrLn $ colorError "@ No such algorithm."
      inputSearch