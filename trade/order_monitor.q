// --------------------------------------------------------------------------------------
// Functions to monitor the status of an order and cancel if needed
// --------------------------------------------------------------------------------------

// gets the status of the 
.trade.getStatus:{[ids;price]
    (`NEW`FILLED)exec ?[ordertype=`LIMIT;
                            price < .trade.currentHigh[price];
                            price > .trade.currentLow[price]] 
                    from order where id in ids
 }

// Checks and updates env variables if orders have been filled (Sold)
.trade.checkOrders:{[price]
    ids:exec id from order where status=`NEW;       // Finds orders recorded as open 
    ids:where (ids!.trade.getStatus[ids;price])=`FILLED;  // Finds orders that are filled
    if[count ids;                                   // Update if any are filled
        filled:select sym,time:.trade.time[],side,qty,price,total,id from order where id in ids;
        `trade upsert filled;
        .trade.bank+:0^sum filled`total;
        .trade.qty-:0^sum filled`qty;
        update status:`FILLED from `order where id in ids]
 }

.trade.cancelOrder:{
    update status:`CANCELLED from `order where status=`NEW;
 }

.trade.currentLow:{[price]
    price
 }

.trade.priv.currentLow:{[price]
    last candle_data`low
 }

.trade.currentHigh:{[price]
    price
 }

.trade.currentHigh:{[price]
    last candle_data`high
 }

if[ENV~`dev;
    .trade.currentLow:.trade.priv.currentLow;
    .trade.currentHigh:.trade.priv.currentHigh]