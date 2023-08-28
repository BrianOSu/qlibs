//----------------------------------------------------------------------------------------------------------------------
// Public CEX WS API
// .cex.ping
//
// .qlibs.load"../cex/ws/public.q"
//
//----------------------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------------------
// Load Libs
//----------------------------------------------------------------------------------------------------------------------

.qlibs.load"../cex/ws/schemas.q"
.qlibs.load"../cex/ws/websocket.q"



//----------------------------------------------------------------------------------------------------------------------
// Helper functions
//----------------------------------------------------------------------------------------------------------------------

// Open a handle to the cex websocket
.cex.open:{
    res:(.cex.url)"GET /ws-public HTTP/1.1\r\nHost: api.plus.cex.io\r\n\r\n";
    if[null res[0];
        'res[1]];
    neg res[0]
 }

// Overwrite to handle updates as needed
.cex.upd:upsert


//----------------------------------------------------------------------------------------------------------------------
// Public API Functions
//----------------------------------------------------------------------------------------------------------------------

.cex.orderBook:{
    .cex.h[.j.j `e`oid`data!("get_order_book"; string .z.p; ((),`pair)!enlist "BTC-GBP")]
 }

.cex.subOrderBook:{
    .cex.h[.j.j `e`oid`data!("order_book_subscribe"; string .z.p; ((),`pair)!enlist "BTC-GBP")]
 }

.cex.tradeHistory:{
    .cex.h[.j.j `e`oid`data!("get_trade_history"; string .z.p; ((),`pair)!enlist "BTC-GBP")]
 }

.cex.subTrade:{
    .cex.h[.j.j `e`oid`data!("trade_subscribe"; string .z.p; ((),`pair)!enlist "BTC-USD")]
 }

.cex.unsubTrade:{
    .cex.h[.j.j `e`oid`data!("trade_unsubscribe"; string .z.p; ((),`pair)!enlist "BTC-GBP")]
 }

.cex.ticker:{
    .cex.h[.j.j `e`oid`data!("get_ticker"; string .z.p; ((),`pair)!enlist "BTC-GBP")]
 }

.cex.serverTime:{
    .cex.h[.j.j `e`oid`data!("get_server_time"; string .z.p; ()!())]
 }

.cex.pairsInfo:{
    .cex.h[.j.j `e`oid`data!("get_pairs_info"; string .z.p; ()!())]
 }

.cex.currenciesInfo:{
    .cex.h[.j.j `e`oid`data!("get_currencies_info"; string .z.p; ()!())]
 }

.cex.processingInfo:{
    .cex.h[.j.j `e`oid`data!("get_processing_info"; string .z.p; ()!())]
 }


//----------------------------------------------------------------------------------------------------------------------
// Handlers for CEX Responses
//----------------------------------------------------------------------------------------------------------------------

.cex.r.tradeHistorySnapshot:{
    if[not "ok"~x`ok;
        :show "trade history snapshot error"];
    .cex.upd[`trade]`dateISO xasc update pair:`$x[`data;`pair], `$side,
                                         {@["Z"$;x;x]} each dateISO, {@["F"$;x;x]} each price, {@["F"$;x;x]} each amount
                                            from x[`data;`trades]
 }

.cex.r.tradeUpdate:{
    if[not "ok"~x`ok;
        :show "trade update error"];
    .cex.upd[`trade] update `$pair, `$side,
                            @["Z"$; dateISO; dateISO], @["F"$; price; price], @["F"$; amount; amount]
                                from x[`data]
 }


//----------------------------------------------------------------------------------------------------------------------
// Handlers for data returned from Cex
//----------------------------------------------------------------------------------------------------------------------

.z.ts:{
    .cex.ping[]
 }

.z.ws:{
    x:.j.k x;
    $["pong"~x`e;                 .cex.r.pong[x];
      "tradeHistorySnapshot"~x`e; .cex.r.tradeHistorySnapshot[x];
      "tradeUpdate"~x`e;          .cex.r.tradeUpdate[x];
                                  (::)];
 }

.cex.h:.cex.open[]

\t 5000