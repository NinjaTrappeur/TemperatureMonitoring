module Const (dbPath, dbTable) where

import Database.SQLite

dbPath :: String
dbPath = "/home/minoulefou/.config/tSensor/data.db"

dbTable :: TableName
dbTable = "MEASURES"
