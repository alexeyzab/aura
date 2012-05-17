-- Utility functions that don't fit in a particular library.

module Utilities where

import System.Process (readProcess, readProcessWithExitCode)
import System.Exit (ExitCode(..))
import Data.List (dropWhileEnd)
import Text.Regex.Posix ((=~))

type Pattern = (String,String)

-- Like break, but kills the element that triggered the break.
hardBreak :: (a -> Bool) -> [a] -> ([a],[a])
hardBreak _ [] = ([],[])
hardBreak p xs = (firstHalf, secondHalf')
    where firstHalf   = takeWhile (not . p) xs
          secondHalf  = dropWhile (not . p) xs
          secondHalf' = if null secondHalf then [] else tail secondHalf

lStrip :: String -> String
lStrip xs = dropWhile (== ' ') xs

rStrip :: String -> String
rStrip xs = dropWhileEnd (== ' ') xs

tripleSnd :: (a,b,c) -> b
tripleSnd (a,b,c) = b

didProcessSucceed :: FilePath -> [String] -> String -> IO Bool
didProcessSucceed cmd args stdin = do
  (exitStatus,_,_) <- readProcessWithExitCode cmd args stdin
  case exitStatus of
    ExitSuccess -> return True
    _           -> return False

-- Replaces a (p)attern with a (t)arget in a line if possible.
replaceByPatt :: [Pattern] -> String -> String
replaceByPatt [] line = line
replaceByPatt ((p,t):ps) line | p == r    = replaceByPatt ps (b ++ t ++ a)
                              | otherwise = line
                         where (b,r,a) = line =~ p :: (String,String,String)

-- I'd like a less hacky way to do this.
-- THIS DOESN'T WORK
terminalWidth :: IO Int
terminalWidth = do
  heightAndWidth <- readProcess "stty" ["size"] ""
  return . read . last . words $ heightAndWidth