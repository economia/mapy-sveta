window.init = (data) ->
    countriesById = d3.map!
    for {id, zeme:name, typ:type, popis:tooltip} in data.staty
        countriesById.set id, {name, type, tooltip}

    new Worldmap countriesById

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
    (@data) ->
        @computeDimensions 650 500
        @projection = d3.geo.mercator!
            ..precision 0.1
        @project \eusa
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

        boundaries = topojson.feature world, world.objects.countries .features
        @svg.selectAll \path.country
            .data boundaries
            .enter!
            .append \path
                ..attr \class \country
                ..attr \d @path
                ..attr \fill ({id}) \none

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
