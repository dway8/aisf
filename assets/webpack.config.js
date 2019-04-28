const path = require("path");
const glob = require("glob");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const UglifyJsPlugin = require("uglifyjs-webpack-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");

module.exports = (env, options) => ({
    optimization: {
        minimizer: [
            new UglifyJsPlugin({
                cache: true,
                parallel: true,
                sourceMap: false,
            }),
            new OptimizeCSSAssetsPlugin({}),
        ],
    },
    entry: {
        "./js/app.js": ["./js/app.js"].concat(glob.sync("./vendor/**/*.js")),
    },
    output: {
        filename: "app.js",
        path: path.resolve(__dirname, "../priv/static/js"),
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: "babel-loader",
                },
            },
            {
                test: /\.css$/,
                use: [MiniCssExtractPlugin.loader, "css-loader"],
            },

            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: [
                    {
                        loader: "elm-hot-webpack-loader",
                    },
                    {
                        loader: "elm-webpack-loader",
                        options: {
                            verbose: true,
                            // warn: true,
                            debug: true,
                            pathToElm: "./node_modules/.bin/elm",
                        },
                    },
                ],
            },
        ],
    },
    devServer: {
        headers: {
            "Access-Control-Allow-Origin": "*",
        },
        stats: {
            assets: false,
            cached: false,
            cachedAssets: false,
            children: false,
            chunks: false,
            colors: true,
            depth: true,
            entrypoints: true,
            errorDetails: true,
            hash: false,
            modules: true,
            source: true,
            timings: true,
            version: false,
            warnings: true,
        },
    },
    plugins: [
        new MiniCssExtractPlugin({ filename: "../css/app.css" }),
        new CopyWebpackPlugin([{ from: "static/", to: "../" }]),

        function() {
            if (typeof this.options.devServer.hot === "undefined") {
                this.plugin("done", function(stats) {
                    if (
                        stats.compilation.errors &&
                        stats.compilation.errors.length
                    ) {
                        console.log(stats.compilation.errors);
                        process.exit(1);
                    }
                });
            }
        },
    ],

    performance: {
        hints: false,
    },
});
