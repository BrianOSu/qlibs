.str.toStr:{ 
    $[type[x] in (-10 10h); x;
      type[x]=0h;           @[x; where 10<>type each x; string];
                            string x]
 }

