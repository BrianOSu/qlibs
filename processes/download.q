// --------------------------------------------------------------------------------------
// Load libs
// --------------------------------------------------------------------------------------

.qlibs.load"../binance/api.q"

// --------------------------------------------------------------------------------------
// Env Variables
// --------------------------------------------------------------------------------------

// Symbol to download
.dl.crypto:"MFTUSDT"
.dl.dbpath:`:/home/brian/binance


// --------------------------------------------------------------------------------------
// Helper Functions
// --------------------------------------------------------------------------------------

///
// Creates timerstamp intervals for requesting from binance
// @param s      Date - Start date
// @param e      Date - End date
// @param period Time - Time interval jumps between dates
.dl.generateTS:{[s;e;period]
    s:"p"$s;e:"p"$e;
    period:1000*0D+period;
    l:s+period*til ceiling (e-s)%period;
    1_prev[l],'l
 }

///
// Will date relevant data for date to write
// @param d Date - The date that needs to be written
.dl.writeData:{[d]
    .db.writeTable[.dl.dbpath; d; `$.dl.crypto,"_1m"; select from data where d=`date$openTime]
 }


// --------------------------------------------------------------------------------------
// Download the data
// --------------------------------------------------------------------------------------

show "------------------------------------------------"
show "Downloading Data: ",.dl.crypto
show "------------------------------------------------"
data:raze ./:[.bi.klinesWithin[.dl.crypto;"1m"]; .dl.generateTS[2021.01.20;2021.02.03;00:01]]

dts:distinct `date$data`openTime

show "------------------------------------------------"
show "Writing data"
show "------------------------------------------------"

.dl.writeData each dts

show "------------------------------------------------"
show "Finished"
show "------------------------------------------------"