new Tooltip!watchElements!
countriesById = d3.map!
fillColorsByType = d3.map!
settings = d3.map!
worldTopojson = null
window.init = (data) ->
    for {id, zeme:name, typ:type, popis:tooltip} in data.staty
        countriesById.set id, {name, type, tooltip}
    for {typ:type, color} in data.typy
        fillColorsByType.set type, color
    for {key, value} in data.nastaveni
        settings.set key, value
    somethingLoaded!

d3.json "./topojson/world.json" (err, world) ->
    worldTopojson := world
    somethingLoaded!

loadCounter = 0
somethingLoaded = ->
    if ++loadCounter >= 2 then draw!
draw = ->
    $window = $ window
    width  = $window .width!
    height = $window .height!
    display = settings.get \display
    worldmap = new Worldmap worldTopojson, display, countriesById, fillColorsByType, {width, height}
    $window.on \resize ->
        width  = $window .width!
        height = $window .height!
        worldmap.resize {width, height}


Dimensionable =
    margin:
        top: 10
        right: 0
        bottom: 22
        left: 39
    computeDimensions: (@fullWidth, @fullHeight) ->
        @width = @fullWidth - @margin.left - @margin.right
        @height = @fullHeight - @margin.top - @margin.bottom


class Worldmap implements Dimensionable
    (world, @visiblePart, @data, @fillColors, {width, height}) ->
        @computeDimensions width, height
        @projection = d3.geo.mercator!
            ..precision 0.1
        @project @visiblePart
        @path = d3.geo.path!
            ..projection @projection
        @svg = d3.select \body .append \svg
            ..attr \width @fullWidth
            ..attr \height @fullHeight

        @svg.append \path
            .datum topojson.feature world, world.objects.land
            .attr \class \land
            .attr \d @path

        boundaries = topojson.feature world, world.objects.countries .features
        boundaries .= filter ({id}) ~>
            country = @data.get id
            country && (country.type.length || country.tooltip.length)
        @svg.selectAll \path.country
            .data boundaries
            .enter!
            .append \path
                ..attr \class \country
                ..attr \d @path
                ..attr \data-tooltip ({id}) ~> @data.get id .tooltip
                ..attr \fill ({id}) ~>
                    {type} = @data.get id
                    @fillColors.get type

        @svg.append \path
            .datum topojson.mesh world, world.objects.countries, (a, b) -> a isnt b
            .attr \class \boundary
            .attr \d @path

    project: (area) ->
        center = [0 0]
        switch area
        | \earth
            scale       = @width / Math.PI / 2
            translation = [@width / 2, @height / 2]
        | \world
            scale       = @width / Math.PI / 2 * 1.4
            translation = [@width / 2, @height / 2]
            center       = [0 23]
        | \eusa
            scale       = @width / Math.PI * 1.4
            translation = [@width / 2, @height / 2]
            center      = [-30 48]
        @projection
            ..scale scale
            ..translate translation
            ..center center
    resize: ({width, height})->
        @computeDimensions width, height
        @svg
            ..attr \width @fullWidth
            ..attr \height @fullHeight
        @project @visiblePart
        @svg.selectAll \path
            .attr \d @path


docKey = window.location.hash.substr 1
script = document.createElement \script
    ..type = \text/javascript
    ..src = "http://service.ihned.cz/spreadsheet/bigfilter.php?key=#{docKey}&numsheets=3&cb=init&forcecache=1"
$ 'body' .append script
