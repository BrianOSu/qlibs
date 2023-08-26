//----------------------------------------------------------------------------------------------------------------------
// Binance Websocket API
// https://github.com/binance/binance-spot-api-docs/blob/master/web-socket-streams.md
//
// To load:
// .qlibs.load"../binance/ws/api.q"
//----------------------------------------------------------------------------------------------------------------------

.qlibs.load"../binance/ws/schema.q"

.bi.ws.priv.url:`$":wss://stream.binance.com:9443";


//----------------------------------------------------------------------------------------------------------------------
// Functions for open websocket connects to binance streams
//----------------------------------------------------------------------------------------------------------------------

.bi.ws.priv.open:{
    res:(.bi.ws.priv.url)"GET ",x," HTTP/1.1\r\nHost: stream.binance.com\r\nOrigin: stream.binance.com\r\n\r\n";
    if[null res[0];
        'res[1]];
    res[0]
 }

// Open a stream and capture the handle for the websocket
// @param x String - Sym to subscribe to(lowercase)
.bi.ws.open.aggTrade:{.bi.ws.h.aggTrade:.bi.ws.priv.open["/ws/",x,"@aggTrade"]}

// @param x String - Sym to subscribe to(lowercase)
.bi.ws.open.trade:{.bi.ws.h.trade:.bi.ws.priv.open["/ws/",x,"@trade"]}

.bi.ws.open.miniTicker:{.bi.ws.h.miniTicker:.bi.ws.priv.open["/ws/!miniTicker@arr"]}
.bi.ws.open.ticker:{.bi.ws.h.ticker:.bi.ws.priv.open["/ws/!ticker@arr"]}

// @param x String(s) - List of syms to subscribe to
.bi.ws.open.tickerSyms:{.bi.ws.h.tickerSyms:.bi.ws.priv.open["/stream?streams=","/" sv $[10h=type x; enlist x; x],\:"@ticker"]}


//----------------------------------------------------------------------------------------------------------------------
// Initialise websocket handles as nulls
//----------------------------------------------------------------------------------------------------------------------

.bi.ws.h.aggTrade:0Ni
.bi.ws.h.trade:0Ni
.bi.ws.h.miniTicker:0Ni
.bi.ws.h.ticker:0Ni
.bi.ws.h.tickerSyms:0Ni


//----------------------------------------------------------------------------------------------------------------------
// Functions to massage incoming binance data
//----------------------------------------------------------------------------------------------------------------------

.bi.ws.updateAggTrade:{
    .bi.ws.upd[`aggTrade; select sym:`$s, price:"F"$p, qty:"F"$q from enlist x]
 }

.bi.ws.updateTrade:{
    .bi.ws.upd[`trade; select sym:`$s, tradeId:"j"$t, price:"F"$p, qty:"F"$q from enlist x]
 }

.bi.ws.updateMiniTicker:{
    .bi.ws.upd[`miniTicker; select sym:`$s, close:"F"$c, open:"F"$o, high:"F"$h, low:"F"$l,
                               baseVolume:"F"$v, quoteVolume:"F"$q
                                    from x]
 }

.bi.ws.updateTicker:{
    .bi.ws.upd[`ticker; select sym:`$s, price:"F"$c, qty:"F"$Q from x]
 }

.bi.ws.updateTickerSyms:{ .bi.ws.updateTicker[x`data] }


//----------------------------------------------------------------------------------------------------------------------
// .z handlers
//----------------------------------------------------------------------------------------------------------------------

// Basic handles for incoming websocket data
.z.ws:{
    $[.z.w~.bi.ws.h.tickerSyms;   .bi.ws.updateTickerSyms[.j.k x];
      .z.w~.bi.ws.h.ticker;       .bi.ws.updateTicker[.j.k x];
      .z.w~.bi.ws.h.aggTrade;     .bi.ws.updateAggTrade[.j.k x];
      .z.w~.bi.ws.h.trade;        .bi.ws.updateTrade[.j.k x];
      .z.w~.bi.ws.h.miniTicker;   .bi.ws.updateMiniTicker[.j.k x];
                                  show .j.k x]
 };

.z.wc:{
    show "Websocket closed. Handle: ", string x;

    // Automatically reconnect if handle died
    $[x~.bi.ws.h.ticker;       .bi.ws.open.ticker[];
      x~.bi.ws.h.aggTrade;     .bi.ws.open.aggTrade[];
      x~.bi.ws.h.trade;        .bi.ws.open.trade[];
      x~.bi.ws.h.miniTicker;   .bi.ws.open.miniTicker[];
                               show "Connection was unknown"]
 };


//----------------------------------------------------------------------------------------------------------------------
// Overridable functions
//----------------------------------------------------------------------------------------------------------------------

// Handles how updates should be treated when received from binance
.bi.ws.upd:{x upsert ([]date:(),.z.d; time:(),.z.t) cross y}