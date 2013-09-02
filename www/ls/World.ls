new Tooltip!watchElements!
window.init = (data) ->
    countriesById = d3.map!
    fillColorsByType = d3.map!
    for {id, zeme:name, typ:type, popis:tooltip} in data.staty
        countriesById.set id, {name, type, tooltip}
    for {typ:type, color} in data.typy
        fillColorsByType.set type, color
    $window = $ window
    width  = $window .width!
    height = $window .height!
    worldmap = new Worldmap countriesById, fillColorsByType, {width, height}
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
    (@data, @fillColors, {width, height}) ->
        @computeDimensions width, height
        @projection = d3.geo.mercator!
            ..precision 0.1
        @project \eusa
        @path = d3.geo.path!
            ..projection @projection
        @svg = d3.select \#content .append \svg
            ..attr \width @fullWidth
            ..attr \height @fullHeight
        (err, world) <~ d3.json "./js/world.json"
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
        switch area
        | \earth
            scale       = @width / Math.PI / 2
            translation = [@width / 2, @height / 2]
        | \world
            scale       = @width / Math.PI / 2 * 1.4
            translation = [@width / 2, @height / 2 * 1.4]
        | \eusa
            scale       = @width / Math.PI * 1.4
            translation = [@width / 1.35, @height * 1.07]
        @projection
            ..scale scale
            ..translate translation
    resize: ({width, height})->
        @computeDimensions width, height
        @project \eusa
        @svg.selectAll \path
            .attr \d @path


docKey = window.location.hash.substr 1
script = document.createElement \script
    ..type = \text/javascript
    ..src = "http://service.ihned.cz/spreadsheet/bigfilter.php?key=#{docKey}&numsheets=2&cb=init&forcecache=1"
$ 'body' .append script
