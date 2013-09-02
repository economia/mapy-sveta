(function(){
  var Dimensionable, Worldmap;
  window.init = function(data){
    console.log(data);
    return new Worldmap;
  };
  Dimensionable = {
    margin: {
      top: 10,
      right: 0,
      bottom: 22,
      left: 39
    },
    computeDimensions: function(fullWidth, fullHeight){
      this.fullWidth = fullWidth;
      this.fullHeight = fullHeight;
      this.width = this.fullWidth - this.margin.left - this.margin.right;
      return this.height = this.fullHeight - this.margin.top - this.margin.bottom;
    }
  };
  Worldmap = (function(){
    Worldmap.displayName = 'Worldmap';
    var prototype = Worldmap.prototype, constructor = Worldmap;
    importAll$(prototype, arguments[0]);
    function Worldmap(data){
      var x$, y$, z$, this$ = this;
      this.computeDimensions(600, 500);
      x$ = this.projection = d3.geo.mercator();
      x$.precision(0.1);
      this.project('world');
      y$ = this.path = d3.geo.path();
      y$.projection(this.projection);
      z$ = this.svg = d3.select('body').append('svg');
      z$.attr('width', this.fullWidth);
      z$.attr('height', this.fullHeight);
      d3.json("./js/world-50m.json", function(err, world){
        this$.svg.append('path').datum(topojson.feature(world, world.objects.land)).attr('class', 'land').attr('d', this$.path);
        return this$.svg.append('path').datum(topojson.mesh(world, world.objects.countries, function(a, b){
          return a !== b;
        })).attr('class', 'boundary').attr('d', this$.path);
      });
    }
    prototype.project = function(area){
      var x$;
      switch (area) {
      case 'world':
        x$ = this.projection;
        x$.scale(this.width / Math.PI / 2);
        x$.translate([this.width / 2, this.height / 2]);
        return x$;
      }
    };
    return Worldmap;
  }(Dimensionable));
  function importAll$(obj, src){
    for (var key in src) obj[key] = src[key];
    return obj;
  }
}).call(this);
