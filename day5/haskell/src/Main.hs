{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.List (nub, nubBy, sort, unfoldr)
import Data.Text.Read (decimal)
import qualified Data.Text as T
import qualified Data.Text.IO as T.IO
import qualified Data.Map.Strict as Map

data Point x y = Point x y deriving (Show, Eq, Ord)
type Point2d = Point Integer Integer

unwrapEither :: Either a b -> b
unwrapEither (Right b) = b
unwrapEither (Left _) = error "unwrapEither"

parseLine :: T.Text -> (Point2d, Point2d)
parseLine line = (Point x1 y1, Point x2 y2)
    where
        splitLine = T.splitOn " -> " line
        p1 = unwrapEither $ mapM decimal $ T.splitOn "," $ head splitLine
        p2 = unwrapEither $ mapM decimal $ T.splitOn "," $ last splitLine

        (x1, _) = head p1
        (y1, _) = last p1

        (x2, _) = head p2
        (y2, _) = last p2

enumeratePoints :: (Point2d, Point2d) -> [Point2d]
enumeratePoints (Point x1 y1, Point x2 y2)
  | x1 == x2 = -- vertical line
    [Point x1 y | y <- if y1 < y2 then [y1..y2] else [y2..y1]]
  | y1 == y2 = -- horizontal line
    [Point x y1 | x <- if x1 < x2 then [x1..x2] else [x2..x1]]
  | otherwise = [] -- don't consider diagnol lines

-- I didn't write this myself unfortunately, but it's an implementation of
-- Bresenham's line algorithm from https://wiki.haskell.org/Bresenham%27s_line_drawing_algorithm
--
-- Maybe should've taken the time to try and write this myself, but (A) I didn't know unfoldr existed and
-- (B) it's almost 3 AM and I kinda just want(ed) to be done. So . . . yeah. *shrug*
line :: (Integer, Integer) -> (Integer, Integer) -> [(Integer, Integer)]
line pa@(xa,ya) pb@(xb,yb) = map maySwitch . unfoldr go $ (x1,y1,0)
  where
    steep = abs (yb - ya) > abs (xb - xa)
    maySwitch = if steep then (\(x,y) -> (y,x)) else id

    [(x1,y1),(x2,y2)] = sort [maySwitch pa, maySwitch pb]

    deltax = x2 - x1
    deltay = abs (y2 - y1)
    ystep = if y1 < y2 then 1 else -1

    go (xTemp, yTemp, error)
        | xTemp > x2 = Nothing
        | otherwise  = Just ((xTemp, yTemp), (xTemp + 1, newY, newError))
        where
          tempError = error + deltay
          (newY, newError) = if (2 * tempError) >= deltax
                            then (yTemp + ystep, tempError - deltax)
                            else (yTemp, tempError)

enumeratePointsWithDiagonals :: (Point2d, Point2d) -> [Point2d]
enumeratePointsWithDiagonals (Point x1 y1, Point x2 y2) =
  map (uncurry Point) $ line (x1,y1) (x2,y2) 

pointsFromFile :: ((Point2d, Point2d) -> [Point2d]) -> IO [Point2d]
pointsFromFile enumerator = do
    -- contents <- T.IO.readFile "example-input.txt"
    contents <- T.IO.readFile "input.txt"
    let lines = concatMap (enumerator . parseLine) $ T.lines contents
    return lines


solve :: [Point2d] -> Int
solve points = length $ filter ((>=2) . snd) $ Map.toAscList map
    where
        map = foldl (\acc p -> Map.insertWith (+) p 1 acc) Map.empty points


main :: IO ()
main = do
    points <- pointsFromFile enumeratePoints
    putStrLn $ "Part one solution: " <> show (solve points)

    pointsWithDiagonals <- pointsFromFile enumeratePointsWithDiagonals
    putStrLn $ "Part two solution: " <> show (solve pointsWithDiagonals)
