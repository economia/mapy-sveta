require! {
    fs
}
deferScripts = []
build-styles = (options = {}) ->
    require! stylus
    (err, data) <~ fs.readFile "#__dirname/www/styl/screen.styl"
    data .= toString!
    stylusCompiler = stylus data
        ..include "#__dirname/www/styl/"
    if options.compression
        stylusCompiler.set \compress true
    (err, css) <~ stylusCompiler.render
    throw err if err
    fs.writeFile "#__dirname/www/screen.css", css

build-script = (file, cb) ->
    require! child_process.exec
    (err, result) <~ exec "lsc.cmd -o #__dirname/www/js -c #__dirname/#file"
    throw err if err
    cb?!

build-all-scripts = (cb) ->
    require! child_process.exec
    (err, result) <~ exec "lsc.cmd -o #__dirname/www/js -c #__dirname/www/ls"
    throw err if err
    cb?!

combine-scripts = (options = {}) ->
    require! uglify: "uglify-js"
    (err, files) <~ fs.readdir "#__dirname/www/js"
    files .= filter -> it isnt 'script.js' and it isnt 'script.js.map'
    files .= sort (a, b) ->
        | a in deferScripts =>  1
        | b in deferScripts => -1
        | otherwise         =>  0
    files .= map -> "./www/js/#it"
    minifyOptions = {}
    if not options.compression
        minifyOptions
            ..compress     = no
            ..mangle       = no
            ..outSourceMap = "../js/script.js.map"
            ..sourceRoot   = "../../"
    result = uglify.minify files, minifyOptions

    {map, code} = result
    if not options.compression
        code += "\n//@ sourceMappingURL=./js/script.js.map"
        fs.writeFile "#__dirname/www/js/script.js.map", map
    fs.writeFile "#__dirname/www/script.js", code

run-script = (file) ->
    require! child_process.exec
    (err, stdout, stderr) <~ exec "lsc #__dirname/#file"
    throw err if err
    console.error stderr if stderr
    console.log stdout


relativizeFilename = (file) ->
    file .= replace __dirname, ''
    file .= replace do
        new RegExp \\\\, \g
        '/'
    file .= substr 1
option 'currentfile' 'Latest file that triggered the save' 'FILE'
task \build ->
    build-styles compression: no
    <~ build-all-scripts
    combine-scripts compression: no
task \deploy ->
    build-styles compression: yes
    <~ build-all-scripts
    combine-scripts compression: yes
task \build-styles ->
    build-styles compression: no
task \build-script ({currentfile}) ->
    file = relativizeFilename currentfile
    isServer = \srv == file.substr 0, 3
    if isServer
        run-script file
    else
        <~ build-script file
        combine-scripts compression: no

