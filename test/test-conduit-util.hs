module Main where

import Control.Monad.Error
import Control.Monad.Identity
import Control.Monad.State
import Data.Conduit 
import Data.Conduit.List hiding (take)
import Data.Conduit.Util.Control as CU 
import Data.Conduit.Util.Count 
import System.Exit (exitFailure, exitSuccess)

import Debug.Trace

-- | 

main = do 
  putStrLn "test conduit util here"
  maybe exitFailure (const exitSuccess) testNonIO 
  runErrorT testIO >>= either (const exitFailure) (const exitSuccess) 

-- | 
testNonIO :: Maybe () 
testNonIO = do 
  guard test_dropWhile 
  guard test_takeWhile 
  guard test_takeWhile_2
  guard test_takeWhileR
  guard test_takeWhileR_2 
  guard test_zipStreamWithList 
  guard test_takeFirstN
  guard test_zipSink3

-- | 
testIO :: ErrorT String IO () 
testIO = do 
  liftIO test_countIter >>=  guard 

-- | 

test_countIter :: IO Bool 
test_countIter = do  
    r <- evalStateT (sourceList lst1 $$ countIter) (0::Int)
    return (r == length lst1)
  where 
    lst1 = [1..10]


-- | 

test_dropWhile :: Bool
test_dropWhile = 
    trace ("r = " ++ show r ++ ", e = " ++ show e  ) $ 
      r == e
  where
    lst1 = [1..10] 
    src1 = sourceList lst1 
    r = runIdentity (src1 $$ (CU.dropWhile (<5) >> consume))
    e = Prelude.dropWhile (<5) lst1

-- |

test_takeWhile :: Bool 
test_takeWhile = 
    trace ("r = " ++ show r ++ ", e = " ++ show e) $ 
      r == e 
  where 
    lst1 = [1..10] 
    src1 = sourceList lst1 
    r = runIdentity (src1 $$ (CU.takeWhile (<5) =$ consume))
    e = Prelude.takeWhile (<5) lst1


-- |

test_takeWhile_2 :: Bool 
test_takeWhile_2 = 
    trace ("r = " ++ show r ++ ", e = " ++ show e) $ 
      r == e 
  where 
    lst1 = [1..10] 
    src1 = sourceList lst1 
    r = runIdentity (src1 $$ ((CU.takeWhile (<5) >> CU.takeWhile (<8)) =$ consume))
    e = Prelude.takeWhile (<8) lst1

    

-- |
test_takeWhileR :: Bool 
test_takeWhileR = 
    trace ("r = " ++ show r ++ ", e = " ++ show e) $ 
      r == e 
  where 
    lst1 = [1..10] 
    src1 = sourceList lst1 
    r = runIdentity (src1 $$ CU.takeWhileR (<5) )
    e = Prelude.takeWhile (<5) lst1
 
-- |
test_takeWhileR_2 :: Bool 
test_takeWhileR_2 = 
    trace ("r = " ++ show r ++ ", e = " ++ show e) $ 
      r == e 
  where 
    lst1 = [1..10] 
    src1 = sourceList lst1 
    r = runIdentity (src1 $$ (do xs <- CU.takeWhileR (<5) 
                                 ys <- CU.takeWhileR (<8)
                                 return (xs ++ ys)))
    e = Prelude.takeWhile (<8) lst1
 
   


-- | 

test_zipStreamWithList :: Bool
test_zipStreamWithList  = 
    runIdentity (zipStreamWithList lst1 src2 $$ consume :: Identity [(Int,Int)]) == zip lst1 lst2 
  where
    lst1 = [1..10]
    lst2 = [4..13] 
    src2 = sourceList lst2 

-- | 

test_takeFirstN :: Bool 
test_takeFirstN = runIdentity (sourceList lst1 =$= takeFirstN 5 $$ consume ) == take 5 lst1 
  where 
    lst1 = [1..10] 

-- | 

test_zipSink3 :: Bool 
test_zipSink3 = r == (lst1,sum lst1,product lst1)
  where
    lst1 = [1..10] 
    sink1 = consume
    sink2 = fold (+) 0 
    sink3 = fold (*) 1 
    r = runIdentity (sourceList lst1 $$ zipSinks3 sink1 sink2 sink3)


