{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Monad (forever)
import qualified Data.ByteString.Char8 as B
import qualified Data.ByteString       as BS
import qualified Data.ByteString.Char8 as Char8
import Data.Time.Clock.POSIX
import Database.SQLite
import System.Hardware.Serialport

import Const (dbPath, dbTable)

data Measure = Measure {
    temperature :: Float,
    humidity    :: Float
} deriving (Eq, Show)

main :: IO ()
main = do
    sDat <- getSensorData
    maybe (return ()) saveToDB sDat
    print sDat

getSensorData :: IO (Maybe Measure)
getSensorData = do
   let port = "/dev/ttyUSB0"  -- Linux
   s <- openSerial port defaultSerialSettings { commSpeed = CS9600}
   serData <- recv s 50 
   let lines = Char8.lines serData
   let mes = if length lines > 2
                then Just . getMeasure $ lines !! 1
                else Nothing
   closeSerial s 
   return mes

getMeasure :: BS.ByteString -> Measure
getMeasure line = Measure temp hum
    where
      hum  = read . Char8.unpack $ Char8.takeWhile (/=';') line
      temp = read . tail . Char8.unpack $ Char8.dropWhile (/=';') line

saveToDB :: Measure -> IO ()
saveToDB mes = do
    hDb <- openConnection dbPath 
    row <- getMesRow mes
    res <- insertRow hDb dbTable row
    closeConnection hDb
    print res

getMesRow :: Measure -> IO (Row String)
getMesRow mes = do
    ts <- show . round <$> getPOSIXTime
    return [("TS",ts),
            ("TEMPERATURE", show $ temperature mes),
            ("HUMIDITY",show $ humidity mes)]
    
