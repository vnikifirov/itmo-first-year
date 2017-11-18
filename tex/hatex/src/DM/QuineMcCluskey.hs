{-# LANGUAGE ScopedTypeVariables #-} 

module DM.QuineMcCluskey where

import Control.Arrow ((&&&))
import Control.Monad (forM_, when)
import Data.Text (unpack)
import Data.Tuple (swap)
import Data.List ((\\), union, sortBy, groupBy, nubBy, intersperse, transpose)
import Data.Foldable (toList)
import Data.Function (on)
import Data.Sequence (Seq)
import qualified Data.Sequence as Seq
import Text.LaTeX.Base.Class (fromLaTeX)
import Text.LaTeX.Base.Syntax (LaTeX (..))

import DM.Logic
import DM.CourseworkTruthTable
import qualified Binary as B
import ReportBase

import Debug.Trace

--
-- Types
--

type CubeCombination = (Int, Int)

data Cube = Cube [CubeCombination] (Seq CubeValue)
  deriving (Eq)

data CubeValue = Bound Bool | Unbound
  deriving (Eq)

instance Show Cube where
  show (Cube ls vals) =
    ((mconcat . intersperse ("-") . (show <$>)) ls) <> " " <> mconcat (show <$> (toList vals))

instance Show CubeValue where
  show (Bound True) = "1"
  show (Bound False) = "0"
  show (Unbound) = "X"

instance Render Cube where
  render (Cube ls vals)
    | (length ls) < 2 = rendervals <> "\\quad" <>
        ("\\quad") <> (fromString . mconcat . (intersperse " ") . (show <$>)) ls
    | otherwise = "\\multirowcell{" <> (fromString . show . length) ls <> "}{" <>
        rendervals <> "\\quad" <>
        (fromString . mconcat . (intersperse " \\\\ ") . (show <$>)) ls <> "}"
    where
      rendervals = (mconcat . toList) (render <$> vals) 
  
instance Render CubeValue where
  render (Bound True) = "1"
  render (Bound False) = "0"
  render (Unbound) = "\\textbf{X}"

--
-- Functions
--

zeroCubes :: [BoolTerm] -> [Cube]
zeroCubes = (cube <$>)
  where
    cube (And terms) = Cube [] (Seq.fromList $ (Bound . unwrap) <$> terms)
    unwrap (X _) = True
    unwrap (Not (X _)) = False

numOfOnes :: Cube -> Int
numOfOnes (Cube _ vs) = length . (filter ((==) (Bound True))) . toList $ vs

sortByOnes :: [Cube] -> [Cube]
sortByOnes = sortBy p
  where
    p a b = ((compare `on` numOfOnes) a b) `mappend` ((compare `on` decValue) a b)
    decValue = B.bitsToDec . (valBit <$>) . vallist
    vallist (Cube _ vs) = toList vs
    valBit (Bound True) = 1
    valBit (_) = 0

groupByOnes :: [Cube] -> [[Cube]]
groupByOnes = groupBy ((==) `on` numOfOnes)

combineCubes :: [Cube] -> [Cube]
combineCubes cs = [ combine (c1, i1) (c2, i2) |
    (c1, i1) <- (zip cs [1..]),
    (c2, i2) <- (zip cs [1..]),
    equalUnbound c1 c2,
    let ds = boundDiffs c1 c2 in length ds == 1 ]
  where
    combine (c1@(Cube _ s1), i1) (c2@(Cube _ _), i2) =
      let [d] = boundDiffs c1 c2
      in Cube [(i1, i2)] (Seq.update d Unbound s1)
    boundDiffs :: Cube -> Cube -> [Int]
    boundDiffs (Cube _ s1) (Cube _ s2) =
      (Seq.findIndicesL is1 s1) `diff` (Seq.findIndicesL is1 s2)
      where
        diff a b = (a \\ b) `union` (b \\ a)
    equalUnbound (Cube _ s1) (Cube _ s2) =
      (Seq.findIndicesL isUnbound s1) == (Seq.findIndicesL isUnbound s2)
    isUnbound Unbound = True
    isUnbound _ = False
    is1 (Bound True) = True
    is1 _ = False

combineToMaxCubes :: [Cube] -> [[Cube]]
combineToMaxCubes = reverse . go . pure
  where
    go :: [[Cube]] -> [[Cube]]
    go ([]:maxcubes) = maxcubes
    go acc@(prev:_) = go ((combined prev) : acc)
    combined = dumbJoin . (nubBy dedupe) . sortByOnes . combineCubes
    dedupe (Cube [c1] _) (Cube [c2] _) = (swap c1) == c2
    dedupe _ _ = False
    dumbJoin = go []
      where
        go uniq [] = uniq
        go uniq ((c@(Cube _ srcvs)):cs) =
          case filter (\(Cube _ vs) -> vs == srcvs) cs of
            [] -> go (uniq ++ [c]) cs
            same -> go (uniq ++ [merge (c : same)]) (cs \\ same)
        merge cubes@((Cube _ vs):_) = Cube combs vs
          where
            combs = cubes >>= (\(Cube cbs _) -> cbs) 

insertCubeGroupBreaks :: [[Cube]] -> ([Cube], [Int])
insertCubeGroupBreaks = (go ([], []))
  where
    go acc [] = acc
    go (acc, []) (x:xs) = go (acc ++ x, [length x]) xs
    go (acc, (breaks@(b:_))) (x:xs) = go (acc ++ x, ((length x) + b) : breaks) xs

implicantTable :: LaTeXM ()
implicantTable =
  borderedtable [(LeftColumn, maxcube)] $ do
    hline
    forM_ (zip rows [1..]) tablerow
  where
    tablerow (cells, rowi) = tfreerow (fromLaTeX <$> cells) <> mconcat (rowborders rowi)
    rowborders i = (flip fmap) (zip breaks [1..]) (\(bs, ci) -> if i `elem` bs then (cline ci ci) else mempty)
    breaks = snd <$> table
    rows :: [[LaTeX]] = (transpose . (balance <$>) . (handleMultirow <$>)) cols
    handleMultirow = go []
      where
        go acc [] = acc
        go acc ((r@(TeXRaw rc)):rs) = let c = unpack rc in case splitAt 14 c of
          ("\\multirowcell{", n:_) -> go (acc ++ r : (replicate (read [n] - 1) TeXEmpty)) rs
          _ -> go (acc ++ [r]) rs
        go acc (r:rs) = go (acc ++ [r]) rs
    balance col = if length col < maxcollen
                    then col ++ (replicate (maxcollen - (length col)) mempty)
                    else col
    maxcollen = maximum (length <$> cols)
    cols :: [[LaTeX]] = ((rendertex <$>) . fst) <$> table
    table :: [([Cube], [Int])] = insertCubeGroupBreaks <$> (groupByOnes <$> cubegroups)
    maxcube = length cubegroups
    cubegroups = combineToMaxCubes zcubes
    zcubes = sortByOnes . zeroCubes . (uncurry (++)) . (minterms &&& dontcareminterms) $ truthTable
 
