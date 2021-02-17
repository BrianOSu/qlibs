// --------------------------------------------------------------------------------------
// Env Variables
// --------------------------------------------------------------------------------------

ENV:`qa


// --------------------------------------------------------------------------------------
// Load libs
// --------------------------------------------------------------------------------------

.qlibs.load"../trade/trade.q"

.qlibs.load"../finos/timer/timer.q"


// --------------------------------------------------------------------------------------
// Grab the initial data
// --------------------------------------------------------------------------------------

// 1 minute candles
candle_data:.bi.klines[.trade.crypto;"5m"]


// --------------------------------------------------------------------------------------
// Buy selling Logic
// --------------------------------------------------------------------------------------


.bi.monitorCandles:{
    //Grab latest data
    candle_data,:select from .bi.klines[.trade.crypto;"5m"] where openTime>last candle_data`openTime;

    if[.trade.side~`BUY;
        .trade.buy candle_data]
 }

.bi.monitorPrice:{
    if[.trade.side like "SELL?";
        .trade.sell[candle_data; .bi.price .trade.crypto]]
 }

// --------------------------------------------------------------------------------------
// Kick off initial timers
// --------------------------------------------------------------------------------------

.finos.timer.addPeriodicTimer[.bi.monitorCandles; 60000]
.finos.timer.addPeriodicTimer[.bi.monitorPrice; 1000]
