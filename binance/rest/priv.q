//----------------------------------------------------------------------------------------------------------------------
// Private helper functions
//----------------------------------------------------------------------------------------------------------------------
.bi.priv.url:":https://api.binance.com/api/v3/"

.bi.priv.reqBody:"applicaition/x-www-form-urlencoded \r\nX-MBX-APIKEY: ",.bi.priv.apikey

.bi.priv.body:{[x]
    nonce:string .time.toMilli .z.p;
    x,:"&timestamp=",nonce;
    x,"&signature=",.algo.HMAC256[x;.bi.priv.privkey]
 }

.bi.priv.httpError:{[resp]
    if[99h~type resp; // Errors will be in a dictionary
        if[`msg in key resp; // If the dictionary contains msg its an error
            '"Error received from binance: ",resp`msg]];
    resp
 }

// Sends a simple GET request to Binances Rest API
// e.g https://api.binance.com/api/v3/depth?symbol=DOGEUSDT
.bi.priv.get:{
    .bi.priv.httpError .rest.get[.bi.priv.url,x,"?",.rest.encode y; ()]
 }

// Sends a GET request to Binances Rest API where public/private API keys and timestamp are required
.bi.priv.get1:{
    .bi.priv.httpError .rest.get[.bi.priv.url,x,"?",.bi.priv.body .rest.encode y;
                                 (.bi.priv.reqBody;())]
 }

// Sends a GET request to Binances Rest API where public API key is required
.bi.priv.get2:{
    .bi.priv.httpError .rest.get[.bi.priv.url,x,"?",.rest.encode y; (.bi.priv.reqBody;())]
 }

.bi.priv.post:{
    .bi.priv.httpError .rest.post[.bi.priv.url,x,"?",.bi.priv.body .rest.encode y;
                                  (.bi.priv.reqBody;())]
 }

.bi.priv.delete:{
    .bi.priv.httpError .rest.delete[.bi.priv.url,x,"?",.bi.priv.body .rest.encode y;
                                    (.bi.priv.reqBody;())]
 }


//----------------------------------------------------------------------------------------------------------------------
// Public API wrappers
//----------------------------------------------------------------------------------------------------------------------

.bi.priv.depth:{[s]
    data:.bi.priv.get["depth"; enlist["symbol"]!enlist s];
    data:flip (`bidprice`bidqty`askprice`askqty)!raze flip each data`bids`asks;
    update "F"$bidprice,"F"$bidqty,"F"$askprice,"F"$askqty from data
 }

.bi.priv.trades:{[s]
    data:.bi.priv.get["trades"; enlist["symbol"]!enlist s];
    data:update "F"$price,"F"$qty,"F"$quoteQty,.time.fromMilli time from data;
    select date:"d"$time,"t"$time,price,qty,quoteQty from data
 }

.bi.priv.historicalTrades:{[s]
    data:.bi.priv.get2["historicalTrades"; enlist["symbol"]!enlist s];
    data:update "F"$price,"F"$qty,"F"$quoteQty,.time.fromMilli time from data;
    select date:"d"$time,"t"$time,price,qty,quoteQty from data
 }

.bi.priv.aggTrades:{[s]
    data:.bi.priv.get["aggTrades"; enlist["symbol"]!enlist s];
    select date:"d"$.time.fromMilli T,time:"t"$.time.fromMilli T,price:"F"$p,qty:"F"$q from data
 }

.bi.priv.klines:{[dict]
    data:.bi.priv.get["klines"; dict];
    data:flip (`ot`o`h`l`c`v`ct`qv`n`b`q`i)!flip data;
    select openTime:.time.fromMilli ot,closeTime:.time.fromMilli ct,
           open:"F"$o, high:"F"$h, low:"F"$l, close:"F"$c,
           volumne:"F"$v,qouteVolume:"F"$qv,trades:n from data
 }

.bi.priv.avgPrice:{[s] "F"$.bi.priv.get["avgPrice";enlist["symbol"]!enlist s]`price}

.bi.priv.24hr:{[s] .bi.priv.get["ticker/24hr";enlist["symbol"]!enlist s]}

.bi.priv.price:{[s]
    $[count s;
        "F"$.bi.priv.get["ticker/price";enlist["symbol"]!enlist s]`price;
        update "F"$price from .bi.priv.get["ticker/price";()!()]]
 }

.bi.priv.bookTicker:{[s]
    $[count s;
        "F"$1_.bi.priv.get["ticker/bookTicker";enlist["symbol"]!enlist s];
        update "F"$bidPrice,"F"$bidQty,"F"$askPrice,"F"$askQty from .bi.priv.get["ticker/bookTicker";()!()]]
 }


//----------------------------------------------------------------------------------------------------------------------
// Private API functions requiring public/private api keys
//----------------------------------------------------------------------------------------------------------------------

.bi.priv.queryOrder:{[s;id]
    .bi.priv.get1["order";("symbol";"orderId")!(s;id)]
 }

.bi.priv.cancelOrder:{[s;id]
    .bi.priv.delete["order";("symbol";"orderId")!(s;id)]
 }

.bi.priv.cancelAllOrders:{[s]
    .bi.priv.delete["openOrders";enlist["symbol"]!enlist s]
 }

.bi.priv.openOrders:{[s]
    data:.bi.priv.get1["openOrders";enlist["symbol"]!enlist s];
    $[count data;
        update `$symbol,`$side,.time.fromMilli time,"F"$price,"F"$origQty,"j"$orderId
            from data;
        .bi.schema.allOrders]
 }

.bi.priv.allOrders:{[s]
    data:.bi.priv.get1["allOrders";enlist["symbol"]!enlist s];
    $[count data;
        update `$symbol, `$side, `$status, .time.fromMilli[time], "F"$price, "F"$origQty,
                "F"$executedQty, "F"$cummulativeQuoteQty, "F"$stopPrice, "j"$orderId
            from data;
        .bi.schema.allOrders]
 }

.bi.priv.account:{
    update `$asset, "F"$free, "F"$locked from .bi.priv.get1["account";()!()]`balances
 }

.bi.priv.myTrades:{[s]
    data:.bi.priv.get1["myTrades";enlist["symbol"]!enlist s];
    $[count data;
        update `$symbol, .time.fromMilli[time], "F"$price, "F"$qty, "F"$quoteQty, "j"$orderId
            from data;
        .bi.schema.trades]
 }

// Base order function
.bi.priv.order:{[s;sd;t;dict]
    d:("symbol";"side";"type")!(s;sd;t);
    .bi.priv.post["order";d,dict]
 }

// Test if inputs are valid for orders. Returns error if something is wrong, otherwise returns nothing
.bi.priv.test.order:{[s;sd;t;dict]
    d:("symbol";"side";"type")!(s;sd;t);
    .bi.priv.post["order/test";d,dict]
 }


.bi.priv.limitOrder:{[s;sd;t;q;p]
    .bi.priv.order[s;sd;"LIMIT";("timeInForce";"quantity";"price")!(t;string q;string p)]
 }

.bi.priv.marketOrder:{[s;sd;qty;qouteQty]
    if[(qty>0) and qouteQty>0;
        '"Quantity and quoteOrderQty supplied for market order"];

    $[qty>0;
        .bi.priv.order[s;sd;"MARKET";enlist["quantity"]!enlist string qty];
        .bi.priv.order[s;sd;"MARKET";enlist["quoteOrderQty"]!enlist string qouteQty]]
 }

.bi.priv.stopLoss:{[s;sd;q;p]
    .bi.priv.order[s;sd;"STOP_LOSS";("quantity";"stopPrice")!(string q;string p)]
 }

.bi.priv.stopLossLimit:{[s;sd;t;q;p;sp]
    .bi.priv.order[s;sd;"STOP_LOSS";("timeInForce";"quantity";"price";"stopPrice")!(t;string q;string p;string sp)]
 }

.bi.priv.takeProfit:{[s;sd;q;p]
    .bi.priv.order[s;sd;"TAKE_PROFIT";("quantity";"stopPrice")!(string q;string p)]
 }

.bi.priv.takeProfitLimit:{[s;sd;t;q;p;sp]
    .bi.priv.order[s;sd;"TAKE_PROFIT_LIMIT";("timeInForce";"quantity";"price";"stopPrice")!(t;string q;string p;string sp)]
 }

// @param s  String - Symbol for limit order
// @param sd String - Side of order to plce
// @param q  Float  - Quantity of limit order
// @param p  Float  - Price of limit order
// @param sp Float  - Price of limit order
// @param sl Float  - Price of limit order
// @param t  String - Time in force e.g. Good till cancelled (GTC)/Fill or Kill (FOK)/Immediate or Cancel (IOC)
.bi.priv.oco:{[s;sd;q;p;sp;dict]
    d:("symbol";"side";"quantity";"price";"stopPrice")!(s;sd;q;p;sp);
    .bi.priv.post["order/oco";d,dict]
 }

.bi.priv.ocoStopLoss:{[s;sd;q;p;sp]
    .bi.priv.oco[s;sd;q;p;sp;()!()]
 }

.bi.priv.ocoStopLossLimit:{[s;sd;q;p;sp;sl;t]
    d:("stopLimitPrice";"stopLimitTimeInForce")!(sl;t);
    .bi.priv.oco[s;sd;q;p;sp;d]
 }