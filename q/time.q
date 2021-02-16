.time.toQEpoch:{1970.01.01D00+1000000*"j"$x}

.time.toQEpoch1:{
    x:$[10h~type x; "J"$x;
         0h~type x; $[10h~type first x; "J"$x; (::)];
                    "j"$x];
    1970.01.01D00+1000000000*x
 }

.time.toLinuxEpoch:{floor(x-1970.01.01D00:00)%1e6}

.time.toLinuxEpoch1:{floor(x-1970.01.01D00:00)%1e9}