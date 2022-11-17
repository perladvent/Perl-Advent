$(function () {
    ////////////////////////////////////////////////////////////////////////
    // add the data to the graph as nodes and edges
    ////////////////////////////////////////////////////////////////////////

    // note that data was loaded into the global 'data' variable in
    // stepford.js which was loaded prior to this script 

    var graph = Viva.Graph.graph();

    // add the filtered data to the graph
    var nodesAlreadyAdded = {};
    var maybeAddNode = function(nodeName) {
        if (nodesAlreadyAdded[nodeName])
            return;
        nodesAlreadyAdded[nodeName] = 1;
        graph.addNode(nodeName);
    }
    var addEdge = function(from,to) {
        maybeAddNode(from);
        maybeAddNode(to);
        graph.addLink(from, to);
    }
    for (var key in data)
         for (var index = 0; index<data[key].length; index++)
            addEdge( key, data[key][index] );

    ////////////////////////////////////////////////////////////////////////
    // graph rendering
    ////////////////////////////////////////////////////////////////////////

    // custom values here that alter the layout that were chosen by trial and
    // error until the graph didn't look as bad as it does now
    var layout = Viva.Graph.Layout.forceDirected(graph, {
        springLength : 100,
        springCoeff : 0.0001,
        dragCoeff : 0.0002,
        gravity : -9,

        // make links from dists to modules smaller than modules to dists
        springTransform: function (link, spring) {
            if (link.fromId == 'cpanfile') {
                spring.length = 200;
                return;
            }
            if (link.fromId.match(/^mod:/)) {
                spring.length = 10;
                return;
            }
            spring.length = 10;
            return;
         }
    });

    var graphics = Viva.Graph.View.webglGraphics();

    // custom colors for the nodes depeneding on what they are
    graphics
        .node(function(node){
            if (node.id == 'cpanfile')
                return Viva.Graph.View.webglSquare(10, '#ffffff');
            if (node.id.match(/^mod:/))
                return Viva.Graph.View.webglSquare(10, '#aaaaaa');
            if (node.id.match(/^dist:/))
                return Viva.Graph.View.webglSquare(10, '#666666');
        })

    // the WebGL mode of VivaGraph doesn't have node labels so
    // we implement it ourselves with DOM objects positioned in
    // the right place.  The 'placeNode' function is a callback
    // that allows us to move the label to the right place when
    // the node is created / whenever it's moved
    var domLabels = Object.create(null);
    graph.forEachNode(function(node) {
      var label = document.createElement('span');
      label.classList.add('node-label');
      label.innerText = node.id.replace(/[^:]+:/,'');  // remove 'mod:'/'dist:'
      domLabels[node.id] = label;
      document.body.appendChild(label);
    });
    graphics.placeNode(function(ui, pos) {
        var domPos = { x: pos.x, y: pos.y };
        graphics.transformGraphToClientCoordinates(domPos);

        // then move corresponding dom label to its own position:
        var nodeId = ui.node.id;
        var labelStyle = domLabels[nodeId].style;
        labelStyle.left = domPos.x + 'px';
        labelStyle.top = domPos.y + 'px';
    });

    var renderer = Viva.Graph.View.renderer(graph, {
        layout      : layout,
        graphics    : graphics,
        interactive : 'node drag',   // scroll is disabled!
        container   : document.body  // the whole web page is the graph
    });

    // this renders then "freezes" the graph.  By default VivaGraph
    // will keep adjusting the graph forever, bouncing it as you pull the
    // nodes this way and that.  However, this makes the graph jiggle contantly
    // when it's as interconnected as a CPAN dependancy graph, so I turn it off
    // run layout for as many iterations as we want before
    for (var i = 0; i < 100; ++i)    // 100 bounces before we freeze
        layout.step();               // to get the graph into the right place
    renderer.run();
    renderer.pause();

    // make the buttons zoom in and zoom out
    $(".zoomin").click(function () { renderer.zoomIn(); });
    $(".zoomout").click(function () { renderer.zoomOut(); });
});
