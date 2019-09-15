// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import { Elm } from "../src/Main.elm";

var cookies = document.cookie.split(";");
var isAdmin = false;
for (var i = 0; i < cookies.length; ++i) {
    var pair = cookies[i].trim().split("=");
    if (pair[0] == "isAdmin") {
        console.log("Found admin cookie");
        isAdmin = true;
    }
}
var flags = { isAdmin, currentYear: new Date().getFullYear() };

var app = Elm.Main.init({
    node: document.getElementById("elm-main"),
    flags,
});
