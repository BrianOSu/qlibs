//////////////////////////////////////////////////////////////////////////////
//   Copyright 2020 Brian O'Sullivan
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////
// Various algos implemented directly in q
// Author: Brian O'Sullivan
// Email: b.osullivan@live.ie
//////////////////////////////////////////////////////


// -------------------------------------------------------------------------------------------------
// Huffman encoding/decoding algo
// https://en.wikipedia.org/wiki/Huffman_coding
// -------------------------------------------------------------------------------------------------

///
// Huffman encodes any given list
// @param  x    List - Input to encode. Any list, strings, numbers or mixed list
// @return List      - 2 item list. First is encoded input. Second is the encoded dictionary mapping
.algo.huffman.encode:{
    freq:asc count each group x;        // Will monitor least used item
    mapping:key[freq]!();               // Will hold encoding mappings
    freq:enlist'[key freq]!value freq;  // keys will be strings instead of chars

    // Apply huffman algo until mapping can encode each element of input
    freq:(1<count first@).algo.huffman.priv.step_encode/(freq;mapping);
    
    // Encode input and return with mapping dictionary for decoding
    mapping:reverse'[freq[1]];
    (raze mapping[x];mapping)
 }

///
// Applies basic huffman algo for each step of overall encoding
// @param  x    List - List of frequence and current mapping
// @return List      - Reduced frequency and updated mapping
.algo.huffman.priv.step_encode:{
    // Identify and remove least used nodes
    x[0]:2_asc x[0],enlist[raze old:key min_nodes]!enlist[sum min_nodes:2#x[0]];

    // Update mapping tree
    x[1;old[0]],:0; x[1;old[1]],:1;
    x
 }

///
// Huffman decodes an input using an ecoded mapping dictionary
// @param  input Long list  - The encoded input
// @param  l     Dictionary - The huffman encoding
// @return List             - The decoded output
.algo.huffman.decode:{[input; l]
    pos:1+til count input;
    // Step through finding positions of items in encoding
    pos: pos where 0<>deltas pos:.algo.huffman.priv.step_decode[;;input;l]\[0;pos];
    // Apply decoding to each item found
    {[a;b;c;d]d? b _ a#c}[;;input;l]':[0;pos]
 }

///
// Helper function to test if chunk of encoding is an element
// @param  s     Int/Long  - Start position to check
// @param  e     Int/Long  - End position to check
// @param  input Long List - The original encoded list
// @param  d     Dict      - Encoder dictionary mapping
// @return Long            - Position to start checking for next input
.algo.huffman.priv.step_decode:{[s;e;input;d]
    $[(s _ e#input) in d; e; s]
 }

// Huffman example test
.algo.huffman.priv.input:"this is an example of a huffman tree"
.algo.huffman.priv.input~.algo.huffman.decode . .algo.huffman.encode .algo.huffman.priv.input


// -------------------------------------------------------------------------------------------------
// HMAC 256
// https://en.wikipedia.org/wiki/HMAC
// -------------------------------------------------------------------------------------------------

.algo.HMAC256:{[msg;secret]
    last " " vs first system"echo -n \"",msg,"\" | openssl dgst -sha256 -hmac \"",secret,"\""
 }
