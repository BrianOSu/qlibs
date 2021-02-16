// --------------------------------------------------------------------------------------
// Fake order/trade functions for use in backtesting/QA
// --------------------------------------------------------------------------------------

// Fake limit order for use in QA
.trade.priv.limitOrder:{[s;sd;t;q;p]
    first -1?1000000000
 }

// Fake limit order for use in QA
.trade.priv.stopLoss:{[s;sd;q;p]
    first -1?1000000000
 }

// Fake market order for use in QA
// Expects candle_data table to exist so that it can estimate a price
.trade.priv.marketOrder:{[s;sd;qty;qouteQty]
    id:first -1?1000000000;
    price:last candle_data`close;
    qty:max(qty;qouteQty%price);
    (`orderId`price`qty`total)!(id;price;qty;price*qty)
 }

.trade.priv.buyMarketOrder:{[s;qouteQty]
    .trade.priv.marketOrder[s;"BUY";0;qouteQty]
 }

.trade.priv.sellMarketOrder:{[s;qty]
    .trade.priv.marketOrder[s;"SELL";qty;0]
 }

.trade.priv.ocoStopLossLimit:{[s;sd;q;p;sp;sl;t]
    (`orderId`price`qty`total)!(-2?1000000000;(sp;p);(q;q);(sp*q;p*q))
 }