//----------------------------------------------------------------------------------------------------------------------
// Private CEX WS API
//  * .cex.authenticate
//  * .cex.accountStatus
//  * .cex.orders
//  * .cex.fundingHistory
//
// .qlibs.load"../cex/ws/private.q"
//
//----------------------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------------------
// Load Libs
//----------------------------------------------------------------------------------------------------------------------

.qlibs.load"../cex/ws/websocket.q"

//----------------------------------------------------------------------------------------------------------------------
// Open connection
//----------------------------------------------------------------------------------------------------------------------

// Open a handle to the cex websocket
.cex.open:{
    res:(.cex.url)"GET /ws HTTP/1.1\r\nHost: api.plus.cex.io\r\n\r\n";
    if[null res[0];
        'res[1]];
    neg res[0]
 }

//----------------------------------------------------------------------------------------------------------------------
// Private API Functions
//----------------------------------------------------------------------------------------------------------------------

.cex.priv.signature_ws:{[nonce]
    upper .algo.HMAC256[nonce,.cex.priv.apikey; .cex.priv.seckey]
 }

.cex.authenticate:{
    sig:last " " vs .cex.priv.signature_ws nonce:string .time.toSec .z.p;
    .cex.h[.j.j `e`auth!("auth"; (`key`signature`timestamp)!(.cex.priv.apikey; sig; nonce))]
 }

.cex.accountStatus:{
    .cex.h[.j.j `e`oid`data!("get_my_account_status_v2"; string .z.p; ()!())]
 }

.cex.orders:{
    .cex.h[.j.j `e`oid`data!("get_my_orders"; string .z.p; ()!())]
 }

.cex.fundingHistory:{
    .cex.h[.j.j `e`oid`data!("get_my_funding_history"; string .z.p; ()!())]
 }


//----------------------------------------------------------------------------------------------------------------------
// Handlers for data returned from Cex
//----------------------------------------------------------------------------------------------------------------------

.z.ts:{
    .cex.ping[]
 }

.z.ws:{
    x:.j.k x;
    $["pong"~x`e; .cex.r.pong[x];
                  show x];
 }

.cex.h:.cex.open[]

.cex.authenticate[]

\t 5000