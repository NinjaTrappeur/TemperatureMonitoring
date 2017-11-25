**Disclaimer:** I did not designed this software for distribuing it, this is mostly a quick hack I made for my own use.

# Temperature and Humidity Monitoring

I am monitoring both the temperature and the humidity of my flat. This software retrieves those metrics from a AM2302 sensor plugged on a Arduino nano.



## Hardware Design

The temperature/humidity AM2302 sensor is plugged to the digital input 2 of the arduino nano. The arduino nano is connected to the computer using the USB serial console at a 9200 bauds rate.

We are sending the data in a CSV format :

```
$HUMIDITY%;$TEMPERATURECELCIUS\n
```

Okay, it's not really coma-separated... But who cares!

## Software Design

The data_processing folder contains a small haskell program that:

1. Read a measure from the serial link.
1. Store this measure in a SQLite DB.

Both the table name and the database file path can be modified in the Const.hs file.

### How to Use it?

First build it. You will need Haskell's stack.

```
cd data_processing && stack install
```

Then setup a cron task to measure the temparature periodically. Let say we want to measure both the temperature
and the humidity every 5 minutes:

```
*/5 * * * * $HOME/.local/bin/sonde-temp
```

You're all set. If you want to check out manually the measures, just query the DB:

```
sqlite3 $PATH_TO_YOUR_DB
select (datetime(TS,'unixepoch')), TEMPERATURE, HUMIDITY from measures;
```
