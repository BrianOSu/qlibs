//----------------------------------------------------------------------------------------------------------------------
// Schema for capturing binance data
//----------------------------------------------------------------------------------------------------------------------

aggTrade:([]
        date:     "d"$();
        time:     "t"$();
        sym:      "s"$();
        price:    "f"$();
        qty:      "f"$());


trade:([]
        date:     "d"$();
        time:     "t"$();
        sym:      "s"$();
        tradeId:  "j"$();
        price:    "f"$();
        qty:      "f"$());

miniTicker:([]
        date:        "d"$();
        time:        "t"$();
        sym:         "s"$();
        close:       "f"$();
        open:        "f"$();
        high:        "f"$();
        low:         "f"$();
        baseVolume:  "f"$();
        quoteVolume: "f"$());

ticker:([]
        date:        "d"$();
        time:        "t"$();
        sym:         "s"$();
        price:       "f"$();
        qty:         "f"$());