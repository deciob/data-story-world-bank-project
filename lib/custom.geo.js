// ***** *****
// extending d3.geo with the peters projection
// see: http://mathworld.wolfram.com/PetersProjection.html
// ***** *****

d3.geo.peters = function(map_height) {

    var scale = 500,
      translate = [480, 250];

    function peters(coordinates) {
        var x_rad = coordinates[0] * Math.PI / 180,
        y_rad = coordinates[1] * Math.PI / 180,
        x = x_rad * Math.cos(44.138 * Math.PI / 180),
        y = -Math.sin(y_rad) * 1 / Math.cos(44.138 * Math.PI / 180);
        return [
        scale * x + translate[0],
        scale * Math.max(-2, Math.min(2, y)) + translate[1]
        ];
    }

    peters.scale = function(x) {
        if (!arguments.length) return scale;
        scale = +x;
        return peters;
    };

    peters.translate = function(x) {
        if (!arguments.length) return translate;
        translate = [+x[0], +x[1]];
        return peters;
    };

    return peters;

};


d3.geo.tristanEdwards = function(map_height) {
 
    var scale = 500,
      translate = [480, 250];

    function tristan(coordinates) {
        var x_rad = coordinates[0] * Math.PI / 180,
        y_rad = coordinates[1] * Math.PI / 180,
        x = x_rad * Math.cos(37.383 * Math.PI / 180),
        y = -Math.sin(y_rad) * 1 / Math.cos(37.383 * Math.PI / 180);
        return [
        scale * x + translate[0],
        scale * Math.max(-2, Math.min(2, y)) + translate[1]
        ];
    }

    tristan.scale = function(x) {
        if (!arguments.length) return scale;
        scale = +x;
        return tristan;
    };

    tristan.translate = function(x) {
        if (!arguments.length) return translate;
        translate = [+x[0], +x[1]];
        return tristan;
    };

    return tristan;

};


