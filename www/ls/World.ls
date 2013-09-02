window.init = (data) ->
    console.log data
    new Worldmap

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
    (data) ->
        @computeDimensions 650 500
        @projection = d3.geo.mercator!
            ..precision 0.1
        @project \world
        @path = d3.geo.path!
            ..projection @projection
        @svg = d3.select \body .append \svg
            ..attr \width @fullWidth
            ..attr \height @fullHeight
        (err, world) <~ d3.json "./js/world-50m.json"
        @svg.append \path
            .datum topojson.feature world, world.objects.land
            .attr \class \land
            .attr \d @path
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
        @projection
            ..scale scale
            ..translate translation
