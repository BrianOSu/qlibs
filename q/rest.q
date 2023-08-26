//----------------------------------------------------------------------------------------------------------------------
// Wrappers for .Q.hmb to interact with Rest APIs
// Author: Brian O'Sullivan
// Email: b.osullivan@live.ie
//----------------------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------------------
// Wrapper for .Q.hmb which changes functionality between 3.5 and 3.6
//----------------------------------------------------------------------------------------------------------------------

.rest.priv.hmb_v35:{[url;method;body]
    .j.k .Q.hmb[`$url;method;body]
 }

.rest.priv.hmb_v36:{[url;method;body]
    .j.k .Q.hmb[url;method;body][1]
 }

.rest.hmb:$[.z.K<3.6; .rest.priv.hmb_v35; .rest.priv.hmb_v36]

.rest.get:.rest.hmb[;`GET;]
.rest.post:.rest.hmb[;`POST;]
.rest.delete:.rest.hmb[;`DELETE;]


//----------------------------------------------------------------------------------------------------------------------
// Helper functions
//----------------------------------------------------------------------------------------------------------------------

// Encodes a dictionary of values to be included in a rest query
// .rest.encode (`a`b)!(1;"a") -> "a=1&b=a"
.rest.encode:{
    if[99h<>type x;
        '".rest.encode requires a dictionary"];
    $[count x;
        "&" sv "=" sv' flip .str.toStr each (key;value) @\: x;
        ""]
 }