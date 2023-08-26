//----------------------------------------------------------------------------------------------------------------------
// Load raw private functions
//----------------------------------------------------------------------------------------------------------------------

.qlibs.load"../binance/rest/keys.q"
.qlibs.load"../binance/rest/schema.q"
.qlibs.load"../binance/rest/priv.q"


//----------------------------------------------------------------------------------------------------------------------
// Public Market Data BINANCE API Functions
// https://github.com/binance/binance-spot-api-docs/blob/master/rest-api.md#market-data-endpoints
// .bi.ping             - Test connectivity to the Rest API.
// .bi.time             - Test connectivity to the Rest API and get the current server time.
// .bi.exchangeInfo     - Current exchange trading rules and symbol information
// .bi.tickSize         - Dictionary of ticksizes for prices
// .bi.stepSize         - Dictionary of stepsizes for quantities
// .bi.depth            - Gets the Order Book
// .bi.trades           - Get recent trades.
// .bi.historicalTrades - Get older trades. Requires knowing a tradeId to fetch from
// .bi.aggTrades        - Get compressed, aggregate trades. Trades that fill at the time, from the
//                        same taker order, with the same price will have the quantity aggregated.
// .bi.klines           - Kline/candlestick bars for a symbol. Klines are uniquely identified by their open time.
// .bi.avgPrice         - Current average price for a symbol.
// .bi.24hr             - 24 hour rolling window price change statistics. Careful when accessing this with no symbol.
// .bi.price            - Latest price for a symbol or symbols.
// .bi.bookTicker       - Best price/qty on the order book for a symbol or symbols.
//----------------------------------------------------------------------------------------------------------------------

.bi.ping:{ .bi.priv.get["ping";()!()]}

.bi.time:{ .time.fromMilli .bi.priv.get["time";()!()]`serverTime}

.bi.exchangeInfo:.bi.priv.get["exchangeInfo";()!()]

// tickSize defines the intervals that a price/stopPrice can be increased/decreased by;
.bi.tickSize:exec first"F"$filters[;0;`tickSize] by `$symbol from .bi.exchangeInfo`symbols

// stepSize defines the intervals that a quantity/icebergQty can be increased/decreased by.
.bi.stepSize:exec first"F"$filters[;2;`stepSize] by `$symbol from .bi.exchangeInfo`symbols

.bi.depth:{[s] .bi.priv.depth s}

.bi.trades:{[s] .bi.priv.trades s}

.bi.historicalTrades:{[s] .bi.priv.historicalTrades s}

.bi.aggTrades:{[s] .bi.priv.aggTrades s}

// @param s string - Symbol e.g. DOGEUSDT
// @param i String - Interval e.g. 1m,3m,5m,15m,30m,1h,2h,4h,6h,8h,12h,1d,3d,1w,1M
.bi.klines:{[s;i] .bi.priv.klines ("symbol";"interval")!(s;i)}

.bi.klinesWithin:{[s;i;st;et]
    .bi.priv.klines ("symbol";"interval";"startTime";"endTime";"limit")!(s;i;.time.toMilli st;.time.toMilli et;1000)
 }

//returns avg price for last 5 mins
.bi.avgPrice:{[s] .bi.priv.avgPrice s}

.bi.24hr:{[s].bi.priv.24hr s}

.bi.price:{[s].bi.priv.price s}

.bi.bookTicker:{[s].bi.priv.bookTicker s}


//----------------------------------------------------------------------------------------------------------------------
// Private Account Endpoints Binance API Functions
// https://github.com/binance/binance-spot-api-docs/blob/master/rest-api.md#account-endpoints
// .bi.balance          - Returns the balance for the given symbol
// .bi.queryOrder       - Returns the status of an order
// .bi.cancelOrder      - Cancels an order and returns the status as confirmation
// .bi.cancelAllOrders  - Cancels all orders and returns their status as confirmation
// .bi.openOrders       - Show the current open orders
// .bi.allOrders        - Shows all historic orders
// .bi.trades           - Shows trades side,qty,price,total,etc
//
// Order types
// .bi.limitOrder       - Standard limit order
// .bi.marketOrder
// .bi.buyMarketOrder
// .bi.sellMarketOrder
// .bi.stopLoss         - Executes a market order when the price price is reached
// .bi.stopLossLimit    - Creates a limit order when the stop price is reached
// .bi.takeProfit       - Executes a market order when the stop price is reached
// .bi.takeProfitLimit  - Executes a market order when the stop price is reached
//----------------------------------------------------------------------------------------------------------------------

.bi.balance:{[s]
    select from .bi.priv.account[] where asset=s
 }

.bi.queryOrder:{[s;id]
    `$.bi.priv.queryOrder[s;id]`status
 }

.bi.cancelOrder:{[s;id]
    `$.bi.priv.cancelOrder[s;id]`status
 }

.bi.cancelAllOrders:{[s]
    `$.bi.priv.cancelAllOrders[s]`status
 }

.bi.openOrders:{[s]
    select symbol,time,side,qty:origQty,price,total:origQty*price,id:orderId from .bi.priv.openOrders s
 }

.bi.allOrders:{[s]
    select symbol,time,side,qty:origQty,price,total:origQty*price,id:orderId,status from .bi.priv.allOrders s
 }

.bi.trades:{[s]
    select symbol,time,side:?[isBuyer;`BUY;`SELL],qty,price,total:quoteQty,id:orderId
        from .bi.priv.myTrades[s]
 }

// .bi.limitOrder["DOGEUSDT";"SELL";"GTC";3466;0.085]
// @param s   String - Symbol for limit order
// @param sd  String - Side of order to plce
// @param t   String - Time in force e.g. Good till cancelled (GTC)/Fill or Kill (FOK)/Immediate or Cancel (IOC)
// @param q   Float  - Quantity of limit order
// @param p   Float  - Price of limit order
// @return id Long   - The orderId as confirmation
.bi.limitOrder:{[s;sd;t;q;p]
    p:"f"$.math.rdm[.bi.stepSize `$.trade.crypto; p];
    q:"f"$.math.rdm[.bi.stepSize `$.trade.crypto; q];
    "j"$.bi.priv.limitOrder[s;sd;t;q;p]`orderId
 }

// Supply either the qty or qouteQty leaving the other as 0
// .bi.priv.marketOrder[`DOGEUSDT;`BUY;();100]
// .bi.priv.marketOrder[`DOGEUSDT;`SELL;10000;()]
// @param s        Sym    - Symbol for limit order
// @param sd       Sym    - Side of order to plce
// @param qty      Float  - Quantity of limit order
// @param qouteQty Float  - Qoute order quantity for limit order
.bi.marketOrder:{[s;sd;qty;qouteQty]
    d:.bi.priv.marketOrder[s;sd;qty;qouteQty];
    id:"j"$d`orderId;
    price:("F"$d[`fills;`qty]) wavg "F"$d[`fills;`price];
    qty:"F"$d`executedQty;
    total:"F"$d`cummulativeQuoteQty;
    (`orderId`price`qty`total)!(id;price;qty;total)
 }

// @param s        String - Symbol for limit order
// @param qouteQty Float  - Qty of quote asset you want to spend
.bi.buyMarketOrder:{[s;qouteQty]
    update qty:qty*0.999 from .bi.marketOrder[s;`BUY;0;qouteQty]
 }

// @param s   String - Symbol for limit order
// @param qty Float  - Qty of base asset you want to sell
.bi.sellMarketOrder:{[s;qty]
    qty:"f"$.math.rdm[.bi.stepSize `$s; qty];
    update total:total*0.999 from .bi.marketOrder[s;`SELL;qty;0]
 }

.bi.stopLoss:{[s;sd;q;p]
    p:"f"$.math.rdm[.bi.stepSize `$s; p];
    q:"f"$.math.rdm[.bi.stepSize `$s; q];
    "j"$.bi.priv.stopLoss[s;sd;q;p]`orderId
 }

.bi.stopLossLimit:{[s;sd;t;q;p;sp]
    "j"$.bi.priv.stopLossLimit[s;sd;t;q;p;sp]`orderId
 }

.bi.takeProfit:{[s;sd;q;p]
    "j"$.bi.priv.takeProfit[s;sd;q;p]`orderId
 }

.bi.takeProfitLimit:{[s;sd;t;q;p;sp]
    "j"$.bi.priv.takeProfitLimit[s;sd;t;q;p;sp]`orderId
 }

.bi.ocoStopLoss:{[s;sd;q;p;sp]
    d:.bi.priv.ocoStopLoss[s;sd;q;p;sp];
    ids:"j"$d[`orders;`orderId];
    prices:"F"$d[`orderReports;0;`stopPrice];
    prices,:"F"$d[`orderReports;1;`price];
    qty:"F"$d[`orderReports;0 1;`origQty];
    (`orderId`price`qty`total)!(ids;prices;qty;prices*qty)
 }

.bi.ocoStopLossLimit:{[s;sd;q;p;sp;sl;t]
    d:.bi.priv.ocoStopLossLimit[s;sd;q;p;sp;sl;t];
    ids:"j"$d[`orders;`orderId];
    prices:"F"$d[`orderReports;0 1;`price];
    qty:"F"$d[`orderReports;0 1;`origQty];
    (`orderId`price`qty`total)!(ids;prices;qty;prices*qty)
 }