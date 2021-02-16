// --------------------------------------------------------------------------------------
// Functions to monitor the status of an order and cancel if needed
// --------------------------------------------------------------------------------------

// gets the status of the 
.trade.getStatus:{[ids]
    (`NEW`FILLED)exec ?[ordertype=`LIMIT;
                            price < last candle_data`high;
                            price > last candle_data`low] 
                    from order where id in ids
 }

// Checks and updates env variables if orders have been filled (Sold)
.trade.checkOrders:{
    ids:exec id from order where status=`NEW;       // Finds orders recorded as open 
    ids:where (ids!.trade.getStatus[ids])=`FILLED;  // Finds orders that are filled
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