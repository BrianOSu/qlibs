// n_days exponential moving average
.stats.n_ema:{[n;x] (2%1+n)ema x}

.stats.addEMA:{[tab;col]
    ![tab; (); 0b; (`EMA20`EMA50`EMA100`EMA200)!((.stats.n_ema;20;col);
                                                 (.stats.n_ema;50;col);
                                                 (.stats.n_ema;100;col);
                                                 (.stats.n_ema;200;col))]
 }

// Add True Range column to table of candles
// Expects high/low/close columns to exist
.stats.addTR:{[tab]
    update TR:max(high-low;abs high-close;abs low-close) from tab
 }

///
// Calculates the relative strength index
.stats.rsi:{[tab]
    t:update change:0^close-prev close from -14#select from tab;
    avgUp:exec avg change from t where change>0;
    avgDown:exec avg abs change from t where change<0;
    rs:avgUp%avgDown;
    100-100%1+rs
 }