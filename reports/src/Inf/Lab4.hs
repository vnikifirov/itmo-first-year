module Inf.Lab4 where

import ReportBase

import Data.List (intersperse)
import Control.Monad (forM_, when)
import Text.Printf
import Text.LaTeX.Packages.Graphicx
import Text.LaTeX.Packages.AMSMath

writeReport :: IO ()
writeReport = renderFile "./renders/Inf-Lab4.tex" (execLaTeXM reportTeX)

type R = Int
type I = Int

data Message = Message Int [R] [I]

messages :: [Message]
messages = [ Message 36 [1, 0, 0] [0, 0, 1, 0]
           , Message 63 [0, 1, 0] [1, 1, 0, 0]
           , Message 90 [0, 1, 0] [1, 1, 1, 0]
           , Message 5 [0, 1, 1] [0, 0, 0, 0] ]

message15b :: Message
message15b = Message 41 [0, 1, 1, 1] [0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0]

sumMod2 :: [Int] -> Int
sumMod2 = ((flip mod) 2) . sum

reportTeX :: LaTeXM ()
reportTeX = do
  baseHeader
  document $ do
    baseTitlePage ("Лабораторная работа №4", "Информатика", Just "Вариант 40", "2017 г.")
    sectionstar "Цель работы"
    "Овладеть навыками кодирования и декодирования сообщений с использованием самокорректирующихся кодов."
    sectionstar "Задания"
    enumerate $ do
      item Nothing <> do
        textit "Построить схему декодирования классического кода Хэмминга (7;4)." >> lnbk
        raw "\\begin{figure}[h]\\centering"
        includegraphics [IGWidth (Cm 18)] "../src/Inf/Lab4Circuit7b.pdf"
        raw "\\end{figure}"
      item Nothing <> do
        textit "Выписать последовательности 7-символьного кода, соответствующие варианту работы." >> lnbk >> newline
        borderedtable [(CenterColumn, 8)] $ do
          hline
          tfreerow $ fmap textbf [multirow 2 Nothing "№", "1", "2", "3", "4", "5", "6", "7"]
          trow $ fmap mt ["", "r_1", "r_2", "i_1", "r_3", "i_2", "i_3", "i_4"]
          forM_ messages (\(Message n rs is) -> trow $ fromIntegral <$>
            [n, rs !! 0, rs !! 1, is !! 0, rs !! 2, is !! 1, is !! 2, is !! 3])
      item Nothing <> do
        textit "Показать, имеются ли в принятых сообщениях ошибки, и если имеются, то какие. Написать правильные сообщения." >> lnbk >> newline
        "Рассмотрим синдромы " <> mt "s_1, s_2, s_3" <> " каждой последовательности, вычисляемые как:"
        flalignstar $ do
          syndromeEqs 7 >> raw "&"
        newpage
        forM_ messages (\(Message n rs is) -> do
          parbreak >> textbf ("Сообщение " <> (fromIntegral n)) >> newline
          analyze7BitMessage rs is >> newline)
      item Nothing <> do
        textit "С помощью кругов Эйлера объяснить построение классического кода Хэмминга (7;4)." >> lnbk >> newline
        raw "\\begin{figure}[h]\\centering" 
        includegraphics [IGWidth (Cm 13.6)] "../src/Inf/Lab4Diagram7b.pdf"
        raw "\\end{figure}"
      item Nothing <> do
        textit "Построить схему декодирования классического кода Хэмминга (15;11)."
        raw "\\begin{figure}[h]\\centering"
        includegraphics [IGWidth (Cm 19)] "../src/Inf/Lab4Circuit15b.pdf"
        raw "\\end{figure}"
      item Nothing <> do
        textit "Выписать последовательность 15-символьного кода, соответствующую варианту работы." >> lnbk >> newline
        borderedtable [(CenterColumn, 15)] $ do
          hline
          tfreerow $ fmap (textbf . fromIntegral) [1..15]
          trow $ fmap mt [ "r_1", "r_2", "i_1", "r_3", "i_2", "i_3", "i_4", "r_4"
                         , "i_5", "i_6", "i_7", "i_8", "i_9", "i_{10}", "i_{11}"]
          let (Message _ rs is) = message15b
          trow $ fromIntegral <$>
            [ rs !! 0, rs !! 1, is !! 0, rs !! 2, is !! 1, is !! 2, is !! 3, rs !! 3
            , is !! 4, is !! 5, is !! 6, is !! 7, is !! 8, is !! 9, is !! 10]
      item Nothing <> do
        textit "Показать, имеются ли в принятом сообщении ошибки, и если имеются, то какие. Написать правильное сообщение." >> lnbk >> newline
        "Рассмотрим синдромы последовательности " <> mt "s_1, s_2, s_3, s_4" <> ", вычисляемые как:"
        flalignstar $ do
          syndromeEqs 15 >> raw "&"
        -- hacked together in a few mins :P
        -- ugly as hell
        -- works though
        let (Message _ rs is) = message15b
        (analyzeMessage [ [rs !! 0, is !! 0, is !! 1, is !! 3, is !! 4, is !! 6, is !! 8, is !! 10]
                        , [rs !! 1, is !! 0, is !! 2, is !! 3, is !! 5, is !! 6, is !! 9, is !! 10]
                        , [rs !! 2, is !! 1, is !! 2, is !! 3, is !! 7, is !! 8, is !! 9, is !! 10]
                        , [rs !! 3, is !! 4, is !! 5, is !! 6, is !! 7, is !! 8, is !! 9, is !! 10]
                        ] (mt <$> [ "r_1", "r_2", "i_1", "r_3", "i_2", "i_3", "i_4", "r_4"
                                  , "i_5", "i_6", "i_7", "i_8", "i_9", "i_{10}", "i_{11}" ])
                          [ rs !! 0, rs !! 1, is !! 0, rs !! 2, is !! 1, is !! 2, is !! 3, rs !! 3
                          , is !! 4, is !! 5, is !! 6, is !! 7, is !! 8, is !! 9, is !! 10 ]
                          (".45" <> textwidth) (".50" <> textwidth))
      item Nothing <> do
        textit "Сложить номера всех 5 вариантов заданий. Умножить полученное число на 4. Принять данное число как число информационных разрядов в передаваемом сообщении. Вычислить для данного числа минимальное число проверочных разрядов и коэффициент избыточности." >> lnbk >> newline
        "Минимальное число проверочных разрядов определяется как " <> mt "2^r - r - 1 \\geqslant i" <> "." >> newline >> lnbk
        let for' = flip fmap
        let ns = for' (messages ++ [message15b]) (\(Message n _ _) -> n)
        let rnum = head [ r | r <- [3..], (2^r - r - 1 >= (sum ns)) ] :: Int
        "Число информационных разрядов равно " <> mconcat (intersperse " + " (for' ns (\n -> fromString $ show n)))
        " = " <> fromIntegral (sum ns) <> "." >> newline
        raw $ "Наименьшее возможное $r$ при $i = " <> fromString (show $ sum ns) <> "$ -- $r$ = " <> fromString (show rnum) <> "."
        newline >> lnbk
        "Вычислим коэффициент избыточности, то есть отношениe числа проверочных к общему числу разрядов:" >> newline
        mathDisplay $ do
          raw $ "k = \\frac{r}{r+i}, \\quad k = \\frac{" <> fromString (show rnum) <> "}{" <> fromString (show $ sum ns + rnum) <> "} \\approx " <> fromString (printf "%0.3f" ((fromIntegral rnum) / fromIntegral (sum ns + rnum) :: Double))
    newpage
    sectionstar "Вывод"
    "В ходе работы я рассмотрел базовые принципы помехоустойчивого кодирования данных и реализацию кода Хэмминга." >> parbreak
    "Достаточно низкий коэффициент избыточности и возможность исправления однобитовых ошибок объясняют широкое применение кода -- в частности, в ОЗУ с коррекцией ошибок." >> parbreak
    "Основным ограничением является вероятность пропуска ошибок в случае, когда несколько бит являются некорректными. Одним из способов решения проблемы является использование дополнительного проверочного разряда (бита четности), позволяющего обнаружить, но не исправить, двухбитовые ошибки."

syndromeEqs :: Int -> LaTeXM ()
syndromeEqs blen = mapM_ ((<> lnbk) . eq) [1..(pnum - 1)] <> eq pnum <> raw "&"
  where
    eq s = raw ("s_{" <> stext <> "} &= ") <>
      raw (mconcat $ intersperse " \\oplus " (("r_{" <> stext <> "}") : namedAddends s))
      where
        stext = fromString (show s)
    namedAddends = ((\a -> "i_{" <> fromString (show a) <> "}") <$>) . addends
    addends n = filter (coveredByP n) [1..inum]
    coveredByP n i = ((/= 0) . sum) $ bitwiseAnd (decToBits (ppos n)) (decToBits (ipos i))
    inum = blen - pnum
    pnum = round (logBase 2 (fromIntegral (blen + 1)))
    ppos n = 2^(n - 1)
    ipos 1 = 3
    ipos i = case ipos (i - 1) of
               pos | pow2 (pos + 1) -> pos + 2
               pos -> pos + 1
    pow2 n = (== 0) . sum $ bitwiseAnd (decToBits n) (decToBits (n - 1))

-- All of it can be automated (see syndromeEqs), but I'll pass on this one
-- But really, it's so horrible
-- I swear I don't usually code like that
-- There's just not... enough... time
-- ugh
analyzeMessage :: [[Int]] -> [LaTeXM ()] -> [Int] -> LaTeXM () -> LaTeXM () -> LaTeXM ()
analyzeMessage addends bitLabels sourceMessage rightpaged leftpaged = do
  minipage (Just Top) (rightpaged) $ do
    forM_ (zip ['1'..] equations) equationLine
  minipage (Just Top) (leftpaged) $ do
    "Десятичное значение синдромов последовательности, записанных последовательно (" <>
      (mconcat $ fromIntegral <$> sums) <> "),  равно " <> fromIntegral sumsDec
      <> ", что указывает на " <> if sumsDec == 0
        then "отсутствие ошибки."
        else "ошибку " <> locWithPrep sumsDec <> " бите, которым является "
          <> (bitLabels !! (sumsDec - 1)) <> "."
  when (sumsDec /= 0) $ do
    newline
    "Получим правильное сообщение, инвертировав ошибочный бит: "
    (if (length sourceMessage > 7) then newline else "") -- ahahah
    highlightErr sourceMessage <> raw " \\rightarrow$\\!$ " <> highlightErr correctedMessage
    where
      equationLine (n, eq) = mt ("s_" <> fromString [n] <> "=") <> " " <> eq <> newline
      equations = eqn <$> zip addends sums
      eqn (adds, s) = (math $ mconcat $
        (intersperse $ raw " \\oplus ") (fromIntegral <$> adds))
        <> " " <> (mt "=" <> " " <> fromIntegral s)
      sums = sumMod2 <$> addends
      sumsDec = bitsToDec sums
      correctedMessage =
        let m = sourceMessage
            pos = sumsDec - 1
        in take pos m ++ complement (m !! pos) : drop (pos + 1) m
      highlightErr m =
        let mtext = fromIntegral <$> m
            pos = sumsDec - 1
        in mconcat $ take pos mtext ++ textbf (mtext !! pos) : drop (pos + 1) mtext
      complement 1 = 0
      complement 0 = 1

analyze7BitMessage :: [R] -> [I] -> LaTeXM ()
analyze7BitMessage [r1, r2, r3] [i1, i2, i3, i4] =
  analyzeMessage addends bitLabels sourceMessage (".28" <> textwidth) (".62" <> textwidth)
    where
      addends = [ [r1, i1, i2, i4]
                , [r2, i1, i3, i4]
                , [r3, i2, i3, i4] ]
      bitLabels = mt <$> ["r_1", "r_2", "i_1", "r_3", "i_2", "i_3", "i_4"]
      sourceMessage = [r1, r2, i1, r3, i2, i3, i4]

bitwiseAnd :: [Int] -> [Int] -> [Int]
bitwiseAnd as bs = bitand <$> (zip (pad as) (pad bs))
  where
    pad ns = padding ns ++ ns
    padding ns = take (longest - length ns) (repeat 0)
    longest = max (length as) (length bs)
    bitand (a, b) = if a + b == 2 then 1 else 0

decToBits :: Int -> [Int]
decToBits = reverse . (go [])
  where
    go rems 0 = 0 : rems
    go rems 1 = 1 : rems
    go rems n = (n `rem` 2) : rems ++ (go rems (n `div` 2))

bitsToDec :: [Int] -> Int
bitsToDec = (foldr digitToPower 0) . (zip powers) . reverse
  where
    digitToPower (pow, d) = (+ d * 2^pow)

powers :: [Int]
powers = [0..]

-- This thing cracks me up for some reason
locWithPrep :: Int -> LaTeXM ()
locWithPrep 1 = "в первом"
locWithPrep 2 = "во втором"
locWithPrep 3 = "в третьем"
locWithPrep 7 = "в седьмом"
locWithPrep 11 = "в одиннадцатом"
