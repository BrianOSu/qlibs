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
// Main library loader for qlibs
// Author: Brian O'Sullivan
// Email: b.osullivan@live.ie
//////////////////////////////////////////////////////

show "------------------------------------------------"
show "Loading qlibs";
show "------------------------------------------------"

///
// Set the directory of the qlibs.q file location
.qlibs.priv.dir:"/"sv -1_"/"vs(reverse value {})2;

///
// Loads a given library from qlibs
// @param x String - The library name to be laoded
.qlibs.load:{
    show "------------------------------------------------"
    show "Loading library: ", x;
    @[system;
        "l ",.qlibs.priv.dir,"/",x;
        show "Unable to load libarary: ",x," due to: ",];
    show "Finished library: ", x;
    show "------------------------------------------------"
 };

// Load the qlibs library
.qlibs.load"algos.q"
.qlibs.load"date.q"
.qlibs.load"rest.q"
.qlibs.load"stats.q"
.qlibs.load"string.q"
.qlibs.load"time.q"
.qlibs.load"db.q"

//.qlibs.load"../binance/tp.q"

show "------------------------------------------------"
show "Finished loading qlibs";
show "------------------------------------------------"