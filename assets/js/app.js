// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

import "phoenix_html";

import { Elm } from "../src/Main.elm";
var cookies = document.cookie.split(";");
var isAdmin = false;
for (var i = 0; i < cookies.length; ++i) {
    var pair = cookies[i].trim().split("=");
    if (pair[0] == admin_cookie) {
        isAdmin = true;
    }
}
var flags = { isAdmin, currentYear: new Date().getFullYear() };

var app = Elm.Main.init({
    node: document.getElementById("elm-main"),
    flags,
});
