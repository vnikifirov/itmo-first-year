{-# LANGUAGE AllowAmbiguousTypes #-}

module Inf.Lab3 where

import Data.List
import Data.List.Split
import Data.Function (on)
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Maybe (fromMaybe)
import Control.Arrow ((***))

import Text.Printf

import qualified Inf.Lab3Id as Id
import ReportBase

import Text.LaTeX.Packages.AMSMath
import qualified Text.LaTeX.Packages.Trees.Qtree as T

writeReport :: IO ()
writeReport = renderFile "./renders/Inf-Lab3.tex" (execLaTeXM reportTeX)

reportTeX :: LaTeXM ()
reportTeX = do
  baseHeader
  document $ do
    baseTitlePage ("ЛАБОРАТОРНАЯ РАБОТА №3", "Информатика", Nothing, "2017 г.")
    sectionstar "Цель работы"
    "Овладеть навыками представления данных в различных кодировках."
    sectionstar "Задания"
    enumerate $ do
      item Nothing <> do
        textit "Сформировать сообщение, взяв первые 9 букв от фамилии, от имени и от отчества в верхнем регистре. Если букв оказалось меньше 27, дополнить сообщение чередованием букв А, О, П, Р." >> lnbreak (Mm 1) >> newline
        "Получившееся сообщение: " >> texttt (fromString Id.message)
      item Nothing <> do
        textit "Рассчитать количество информации (энтропию) в полученном сообщении (в битах), используя меру Шеннона: в качестве события принять появление некоторой буквы и рассчитать вероятность её появления, исходя из частоты встречаемости букв в сообщении." >> lnbk
        minipage (Just Top) (".38" <> textwidth) $ do
          vspace (Mm 1)
          tabular Nothing [VerticalLine, ParColumnTop "3cm", VerticalLine, ParColumnTop "2cm", VerticalLine] $ do
            hline >> (textbf "Буква" & textbf "Частота") >> lnbk >> hline
            letterFrequencyRows Id.message
        minipage (Just Top) (".52" <> textwidth) $ do
          vspace (Mm 1)
          "Найдем информационную энтропию полученного сообщения, используя следующую формулу:"
          flalignstar (raw "&" >> "-" >> raw "\\sum_{i=1}^N p_i * \\log_2 p_i" >> raw "&")
          "При " >> math "N = 16" >> ", длине сообщения, равной 27, и частоте встречаемости букв, приведенной в таблице, получаем:"
          flalignstar $ do
            let p = fromString . (printf "%0.4f")
            let r1 = ((3 / 27) * logBase 2 (3 / 27) :: Double)
            let r2 = ((2 / 27) * logBase 2 (2 / 27) :: Double)
            let r3 = ((1 / 27) * logBase 2 (1 / 27) :: Double)
            let i = abs (r1 * 3 + r2 * 5 + r3 * 8)
            raw "&" >> raw "p_{1..3} = " >> frac 3 27 >> quad >> raw "p_{1..3} * log_2 p_{1..3} \\approx " >> p r1 >> lnbk
            raw "&" >> raw "p_{4..8} = " >> frac 2 27 >> quad >> raw "p_{4..9} * log_2 p_{4..9} \\approx " >> p r2 >> lnbk
            raw "&" >> raw "p_{9..16} = " >> frac 1 27 >> quad >> raw "p_{10..16} * log_2 p_{10..16} \\approx " >> p r3 >> lnbreak (Mm 4)
            raw "&" >> raw "i \\approx " >> p i >> raw "&"
      item Nothing <> do
        textit "Записать полученную последовательность в одну строку, посчитать её размер, учитывая, что для хранения используется кодировка UTF-16, т.е. на 1 символ необходимо 2 байта." >> lnbreak (Mm 1) >> newline
        texttt (fromString Id.message) >> ", длина строки = 27, размер = " >> math "27 * 2 = 54" >> " байта, или 432 бита."
      item Nothing <> do
        textit " Используя двоичный код, составить код постоянной длины, с помощью которого можно закодировать исходное сообщение при использовании минимального количества разрядов (обязательно составить таблицу соответствия исходных слов и результирующих). Объяснить количество использованных бит." >> lnbk
        minipage (Just Top) (".38" <> textwidth) $ do
          vspace (Mm 1)
          tabular Nothing [VerticalLine, ParColumnTop "3cm", VerticalLine, ParColumnTop "2cm", VerticalLine] $ do
            hline >> (textbf "Буква" & textbf "Код") >> lnbk >> hline
            fixedWidthCodeRows Id.message
        minipage (Just Top) (".52" <> textwidth) $ do
          vspace (Mm 1)
          "Поскольку количество уникальных букв в последовательности равно 16, нам достаточно четырех бит\
          \ для записи каждого символа " >> (math . raw) "(2^4 = 16)."
      item Nothing <> do
        textit "Посчитать результирующий объём, коэффициент сжатия." >> lnbreak (Mm 1) >> newline
        "Результирующий объем равен 16 символам, умноженным на 4 бита, которыми кодируется каждый из них, то есть 64 битам." >> newline >> newline
        "Коэффициент сжатия определяется как отношение " >> textit "входного " >> "потока к " >> textit "выходному. "
        "Примем входной поток как исходное сообщение в кодировке UTF-16 " >> textit "(см. задание 3)," >> " тогда "
        math ("k = " >> (432 / 64) >> " = " >> (fromString . show) ((432 / 64) :: Float)) >> "."
      
      -- Shannon-Fano
      let (latexTree, codeMap) = ((shannonFanoTree 27) . letterFrequency) Id.message
          codeList = mapToSortedCodeList codeMap

      item Nothing <> do
        textit "Составить код Шеннона-Фано. При ветвлении использовать максимально равные вероятности (при альтернативе, т.е. при равных вероятностях 2 групп, разбивать текущую группу символов на 2 группы, содержащие одинаковое количество символов). Обязательно составить дерево, таблицу соответствия исходных слов и результирующих." >> lnbreak (Mm 1) >> newline
        raw "\\resizebox{\\textwidth}{!}{" >> T.tree id latexTree >> raw "}" >> newline
        codeTable codeList (Map.fromList $ letterFrequency Id.message) 27
        newline >> newline
      item Nothing <> do
        textit "Посчитать результирующий объём, коэффициент сжатия относительно исходного сообщения, средную длину кодового слова." >> lnbreak (Mm 1) >> newline
        codeStats Id.message codeMap codeList
     
      let (prefixTree, prefixCodeMap) = suboptimalPrefixCode Id.message
          prefixCodeList = mapToSortedCodeList prefixCodeMap
      
      item Nothing <> do
        textit "Составить неоптимальный префиксный код (как в примере), подробно прокомментировать свои действия. Обязательно составить дерево, таблицу соответствия исходных слов и результирующих." >> lnbreak (Mm 1) >> newline
        codeTable prefixCodeList (Map.fromList $ letterFrequency Id.message) 27
        landscapemode $ do
          raw "\\begin{table}\\resizebox{0.8\\linewidth}{!}{" >> T.tree id prefixTree >> raw "}\\end{table}"

      item Nothing <> do
        textit "Посчитать результирующий объём, коэффициент сжатия, средную длину кодового слова." >> lnbreak (Mm 1) >> newline
        codeStats Id.message prefixCodeMap prefixCodeList
    
      let (_huffmanRes, _huffmanLog) = huffmanTable . letterFrequency $ Id.message
      let huffmanLog = (splitOn [("", 0)] _huffmanLog) ++ [_huffmanRes]
          (huffmanT, huffmanMap) = huffmanTree huffmanLog
          huffmanCodeList = mapToSortedCodeList huffmanMap

      item Nothing <> do
        textit "Составить код Хаффмана (использовать оптимальные префиксные коды), таблицу, характеризующую действия по построению кода. Обязательно составить дерево, таблицу соответствия исходных слов и результирующих." >> lnbreak (Mm 1) >> newline
        codeTable huffmanCodeList (Map.fromList $ letterFrequency Id.message) 27
        lnbreak (Mm 4) >> newline
        raw "\\resizebox{\\textwidth}{!}{" >> T.tree id huffmanT >> raw "}" >> newline
        newpage
        landscapemode $ do
          raw "\\begin{table}\\resizebox{\\linewidth}{!}{"
          let colf n size = concat $ replicate n [VerticalLine, ParColumnTop size, VerticalLine, ParColumnTop "0.5cm"]
          let cols = (colf 7 "0.7cm" ++ colf 5 "1.2cm" ++ colf 1 "2.2cm" ++ colf 2 "3.5cm") ++ [VerticalLine]
          tabular Nothing cols $ do
            hline >> textbf "П" & textbf "К" >>
              (mconcat $ replicate 14 (raw "&" >> textbf "П" & textbf "К")) >> lnbk >> hline
            let logrows = transpose huffmanLog
            (flip mapM_) logrows (\((lhs, lhf):lt) ->
              (fromString lhs) & (fromIntegral lhf) >>
                  mapM_ (\(s, f) -> raw "&" >> (fromString s) & (fromIntegral f)) lt >> lnbk >> hline)
          raw "}\\end{table}"
      
      item Nothing <> do
        textit "Посчитать результирующий объём, коэффициент сжатия, средную длину кодового слова." >> lnbreak (Mm 1) >> newline
        codeStats Id.message huffmanMap huffmanCodeList
    
    newpage
    sectionstar "Выводы"
    "В ходе работы я рассмотрел основные способы кодирования данных и реализацию базовых алгоритмов. Наименее эффективным способом оказался неоптимальный префиксный код, наиболее эффективным -- алгоритм Хаффмана." >> parbreak
    "Самым простым в реализации, на мой взгляд, был код фиксированной длины; интересно то, что он оказался достаточно оптимальным для моих исходных данных: количество уникальных букв в сообщении составило 16 (" <> raw "$2^4$" >> "), что соответствует кодовому слову длиной 4 бита." >> parbreak
    "Я нашел алгоритм построения кодовой таблицы по Хаффману немногим сложнее в реализации алгоритма Шеннона-Фано, и, учитывая то, что первый обладает лучшими показателями эффективности, я считаю его наиболее подходящим для практического приминения из мною рассмотренных."

codeTable :: [(Char, String)] -> Map Char Int -> Int -> LaTeXM ()
codeTable codelist freqmap msglen =
  tabular Nothing [VerticalLine, ParColumnTop "0.5cm", VerticalLine, ParColumnTop "0.5cm", VerticalLine, ParColumnTop "3.2cm", VerticalLine] $ do
    hline >> (textbf "Б" & textbf "В" & textbf "К") >> lnbk >> hline
    mapM_ render codelist
  where
    render (char, code) = fromString [char] &
      (math (fromIntegral (freqmap Map.! char) / fromIntegral msglen)) & fromString code >> lnbk >> hline

huffmanTree :: [[(String, Int)]] -> (T.Tree (LaTeXM ()), Map Char String)
huffmanTree table = let t@(r:_) = reverse table
                        [(lseq, _), (rseq, _)] = lastTwo r
                        seq = lseq ++ rseq
                    in go [] Map.empty seq t
  where
    lastTwo xs = drop (length xs - 2) xs
    go :: String -> Map Char String -> String -> [[(String, Int)]] -> (T.Tree (LaTeXM ()), Map Char String)
    go codes codemap [c] ([]:_) =
      (T.Leaf $ leafCaption [last codes], Map.insert c codes codemap)
      where
        leafCaption code =
          textbf ("[" <> fromString code <> "] ") <> (fromString [c])
    go codes codemap [c] (r:rs) =
      let [(lseq, _), (rseq, _)] = lastTwo r
       in if [c] == lseq then (T.Leaf $ leafCaption "1", Map.insert c (codes ++ "1") codemap)
          else if [c] == rseq then (T.Leaf $ leafCaption "0", Map.insert c (codes ++ "0") codemap)
          else go codes codemap [c] rs
      where
        leafCaption code =
          textbf ("[" <> fromString code <> "] ") <> (fromString [c])
    go codes codemap cseq (r:rs) =
      let [(lseq, _), (rseq, _)] = lastTwo r
          (lhs, lmap) = go (codes ++ "1") codemap lseq rs
          (rhs, rmap) = go (codes ++ "0") codemap rseq rs
       in if cseq == lseq ++ rseq then (T.Node (Just $ nodeCaption codes) [lhs, rhs], Map.union lmap rmap)
          else go codes codemap cseq rs
       where
         nodeCaption [] = fromString cseq
         nodeCaption codes =
           textbf ("[" <> fromString [last codes] <> "] ") <> fromString cseq

huffmanTable :: [(Char, Int)] -> ([(String, Int)], [(String, Int)])
huffmanTable = ((flip go) []) . (((flip (:) []) *** id) <$>)
  where
    go :: [(String, Int)] -> [(String, Int)] -> ([(String, Int)], [(String, Int)])
    go [u, l] _ = let branch = sorted [u, l] in (branch, [])
    go freqs log =
      let (upper, [(s1, f1), (s2, f2)]) = (splitWithLastTwo . sorted) freqs
          (branch, bfreqs) = ((flip go) log) $ (s1 ++ s2, f1 + f2) : upper
          llog = log ++ [("", 0)] ++ sorted freqs ++ bfreqs
      in (branch, llog)
    splitWithLastTwo xs = splitAt (length xs - 2) xs
    sorted = sortBy ((flip compare) `on` snd)

codeStats :: String -> Map Char String -> [(Char, String)] -> LaTeXM ()
codeStats msg codemap codelist = do
  "Объем сообщения составляет " <> fromIntegral size <> " бит. "
  "Коэффициент сжатия = " <> (math
    (432 / fromIntegral size) <> " " <> math (raw "\\approx") <> " "
      <> (fromString $ printf "%0.3f" ((432 / fromIntegral size) :: Double))) <> "."
  newline >> newline
  "Средняя длина кодового слова = " <> math (kExpl <> raw "\\approx" <> (fromString $ printf "%0.3f" (kRes :: Double)))
  where
    size = sum . ((\c -> length $ codemap Map.! c) <$>) $ msg
    (kExpl, kRes) = codeWeigths (Map.fromList . letterFrequency $ msg) codelist

mapToSortedCodeList :: Map Char String -> [(Char, String)]
mapToSortedCodeList = (sortBy (compare `on` ((fromMaybe 0) . ((flip elemIndex) sortedChars) . fst))) . Map.toList
  where
    sortedChars = fst <$> (letterFrequency Id.message)

suboptimalPrefixCode :: String -> (T.Tree (LaTeXM ()), Map Char String)
suboptimalPrefixCode msg = (go ([], Map.empty) . letterFrequency) msg
  where
    prob freq = frac (fromIntegral freq) (fromIntegral . length $ msg)
    codepart [] = ""
    codepart codes = textbf $ "[" <> fromString [last codes] <> "] "
    go (codes, codemap) [(c, freq)] =
      let newmap = Map.insert c codes codemap
          leaf = T.Leaf leafCaption
      in (leaf, newmap)
      where
        leafCaption = codepart codes <> fromString [c] <> lnbk <> math (prob freq)
    go (codes, codemap) ts@(l:rs) =
      let (rtree, rmap) = go (codes ++ "1", codemap) rs
          (ltree, lmap) = go (codes ++ "0", codemap) [l]
          umap = Map.union codemap (Map.union rmap lmap)
          node = T.Node (Just nodeCaption) [rtree, ltree]
      in (node, umap)
      where
        nodeCaption = codepart codes <> chars <> lnbk <> math ("(" <> probs <> ")")
        chars = fromString $ reverse (fst <$> ts)
        probs = mconcat $ intersperse " + " ((prob . snd) <$> ts)

codeWeigths :: Fractional f => Map Char Int -> [(Char, String)] -> (LaTeXM (), f)
codeWeigths freqs = ((mconcat . init) *** id) .
  (foldr (\(c, code) (tex, sum) ->
    let freq = freqs Map.! c
        newTeX = (frac (fromIntegral freq) 27) : " * " : ((fromString . show . length) code) : " + " : tex
        newSum = sum + ((fromIntegral freq) / 27) * (fromIntegral $ length code)
     in (newTeX, newSum)) ([], 0))

data LeafDirection = LLeft | LRight | LRoot;

shannonFanoTree :: Int -> [(Char, Int)] -> (T.Tree (LaTeXM ()), Map Char String)
shannonFanoTree msglen = node (LRoot, [], Map.empty)
  where
    prob freq = frac (fromIntegral freq) (fromIntegral msglen)
    code LLeft = "1"
    code LRight = "0"
    code LRoot = ""
    node (dir, codes, codemap) [(c, f)] = (T.Leaf caption, newCodemap)
      where
        newCodemap = Map.insert c (codes ++ code dir) codemap
        caption = (textbf $ "[" <> code dir <> "] ")
          <> (fromString [c]) <> lnbk <> math ("(" <> prob f <> ")")
    node (dir, codes, codemap) branch = (T.Node (Just caption) nodes, newCodemap)
      where
        (nodes, newCodemap) = case splitBranch branch of
          ([], []) -> ([], codemap)
          (lhs, []) -> let (lnode, lmap) = (node (LLeft, leafCodes, codemap) lhs)
                       in ([lnode], Map.union codemap lmap)
          (lhs, rhs) -> let (lnode, lmap) = (node (LLeft, leafCodes, codemap) lhs) 
                            (rnode, rmap) = (node (LRight, leafCodes, codemap) rhs)
                        in ([lnode, rnode], Map.union codemap (Map.union lmap rmap))
        leafCodes = codes ++ code dir
        codeCaption = case dir of
          LRoot -> textbf $ ""
          d -> textbf $ "[" <> code d <> "] "
        caption = codeCaption <> (fromString chars) <> lnbk <> math ("(" <> probs <> ")" <> " = " <> probsum)
        chars = fst <$> branch
        probsum = prob . sum . (snd <$>) $ branch
        probs = mconcat $ intersperse " + " ((prob . snd) <$> branch)

splitBranch :: [(a, Int)] -> ([(a, Int)], [(a, Int)])
splitBranch node = go [] node
  where
    go [] [l, r] = ([l], [r])
    go lefts [] = (lefts, [])
    go lefts (r:rights) =
      let nls = lefts ++ [r]
      in if sum (snd <$> nls) > sum (snd <$> rights)
         then (nls, rights) else (go nls rights)

fixedWidthCodeRows :: String -> LaTeXM ()
fixedWidthCodeRows msg = mapM_ row (fixedWidthCode msg)
  where
    row (c, code) = (fromString [c] & fromString code) >> lnbk >> hline

fixedWidthCode :: String -> [(Char, String)]
fixedWidthCode msg = zip chars codewords
  where
    codewords = [ a : b : c : [d] | a <- bits, b <- bits, c <- bits, d <- bits]
    bits = ['0', '1']
    chars = fst <$> (letterFrequency msg)

letterFrequencyRows :: String -> LaTeXM ()
letterFrequencyRows = (mapM_ row) . letterFrequency
  where
    row (char, freq) = (fromString [char] & (fromString . show) freq) >> lnbk >> hline

letterFrequency :: String -> [(Char, Int)]
letterFrequency msg = sortBy descending charFreqTuples
  where
    descending = (flip compare) `on` snd
    charFreqTuples = (\chars@(c:_) -> (c, length chars)) <$> ((group . sort) msg)
