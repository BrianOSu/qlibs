// --------------------------------------------------------------------------------------
// Interface for sending orders/trades and keeping track of positions
// --------------------------------------------------------------------------------------

.qlibs.load"../trade/analytics.q"
.qlibs.load"../trade/order_monitor.q"
.qlibs.load"../trade/priv.q"
.qlibs.load"../binance/api.q"
.qlibs.load"../processes/model_v2.q"

// --------------------------------------------------------------------------------------
// Variables to track quantity/price
// --------------------------------------------------------------------------------------

// Set the initial side of a trade to enter on
.trade.side:`BUY;

// Values to be decided on entering trades
.trade.entryPrice:0f
.trade.exitPrice:0f;
.trade.stopPrice:0f;

// Ensure we're in qa if unset
if[not `ENV~key `ENV;
    ENV:`qa]


// --------------------------------------------------------------------------------------
// Tables to track orders and trades
// --------------------------------------------------------------------------------------

// Book to keep track of orders
order:([]sym:       ();
         time:      ();
         side:      ();
         qty:       ();
         price:     ();
         total:     ();
         id:        ();
         ordertype: ();
         status:    ())

// Book to keep track of trades
trade:([]sym:   ();
         time:  ();
         side:  ();
         qty:   ();
         price: ();
         total: ();
         id:    ())

// --------------------------------------------------------------------------------------
// Trading Functions
//  * .trade.limitOrder   - Sends a limit order 
//  * .trade.stopLoss     - 
//  * .trade.ocoStopLossLimit -
//  * .trade.marketOrder  - Sends a market order
//  * .trade.buyMarketOrder
//  *
// --------------------------------------------------------------------------------------

.trade.limitOrder:{[sym;side;qty;price]
    id:.trade.priv.limitOrder[sym;side;"GTC";qty;price];
    .trade.recordOrder[sym;.trade.time[];side;qty;price;id;`LIMIT];
    id
 }

.trade.stopLoss:{[sym;qty;price]
    id:.trade.priv.stopLoss[sym;"SELL";qty;price];
    .trade.recordOrder[sym;.trade.time[];"SELL";qty;price;id;`$"STOP_LOSS"];
    id
 }

.trade.ocoStopLossLimit:{[sym;qty;price;stopPrice;stopLimitPrice]
    d:.trade.priv.ocoStopLossLimit[sym;"SELL";qty;price;stopPrice;stopLimitPrice;"GTC"];
    .trade.recordOrder[sym;.trade.time[];"SELL";qty;d[`price;0];d[`orderId;0];`$"STOP_LOSS_LIMIT"];
    .trade.recordOrder[sym;.trade.time[];"SELL";qty;d[`price;1];d[`orderId;1];`LIMIT];
    d
 }

.trade.buyMarketOrder:{[sym;qouteQty]
    d:.trade.priv.buyMarketOrder[sym;qouteQty];
    .trade.recordTrade[sym;.trade.time[];"BUY";d`qty;d`price;d`orderId];
    .trade.qty+:d`qty;
    .trade.bank-:d`total;
    d
 }

.trade.sellMarketOrder:{[sym;qty]
    d:.trade.priv.sellMarketOrder[sym;qty];
    .trade.recordTrade[sym;.trade.time[];"SELL";d`qty;d`price;d`orderId];
    .trade.qty-:d`qty;
    .trade.bank+:d`total;
    d
 }


// --------------------------------------------------------------------------------------
// Functions to record orders/trades
// --------------------------------------------------------------------------------------

.trade.recordOrder:{[sym;time;side;qty;price;id;ordertype]
    `order upsert enlist (sym;time;side;qty;price;qty*price;id;ordertype;`NEW)
 } 

.trade.recordTrade:{[sym;time;side;qty;price;id]
    `trade upsert enlist (sym;time;side;qty;price;qty*price;id)
 } 


.trade.time:{
    .z.p
 }

.trade.time_backtest:{
    last candle_data`closeTime
 }


// --------------------------------------------------------------------------------------
// Set interface to be QA or Prod
// --------------------------------------------------------------------------------------

if[ENV~`dev;
    .trade.time:.trade.time_backtest]

if[ENV~`prod;
    .trade.priv.limitOrder:.bi.limitOrder;
    .trade.priv.stopLoss:.bi.stopLoss;
    .trade.priv.marketOrder:.bi.marketOrder;
    .trade.priv.buyMarketOrder:.bi.buyMarketOrder;
    .trade.priv.sellMarketOrder:.bi.sellMarketOrder;
    .trade.priv.ocoStopLossLimit:.bi.ocoStopLossLimit]