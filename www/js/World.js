(function(){
  var Worldmap;
  window.init = function(data){
    return console.log(data);
  };
  Worldmap = (function(){
    Worldmap.displayName = 'Worldmap';
    var prototype = Worldmap.prototype, constructor = Worldmap;
    function Worldmap(data){}
    return Worldmap;
  }());
}).call(this);
