
var w = 1024,
    h = 748,
    node,
    link,
    root;

var formatNumber = d3.format(",d");

var force = d3.layout.force()
    .on("tick", tick)
    .charge(-30)
    .linkDistance(30)
    .size([w, h - 160]);

var vis;

var divisor = 1000 * // Miliseconds per second
              60 * // Seconds per minute
              30 * // Minutes per hour
              1; // Hours we want to divide by

function reload() {
    var sport = activeLabel("sports");
    var file = "/data/retweet." + sport + ".json";
    d3.json(file, function(json) {
        json.nodes.forEach(function(d, i) {
            d.value = +d.value;
        });
        json.links.forEach(function(d, i) {
            d.value = +d.value;
            d.date = parseTime(d.time);
        });
        update(json.nodes, json.links);
    });
}

function update(userList, linkList) {

    d3.selectAll(".chart").selectAll("svg").remove();
    d3.selectAll("#graph").selectAll("svg").remove();

    vis = d3.select("#graph")
            .append("svg:svg")
            .attr("width", w)
            .attr("height", h);

    var nodes = userList, links = linkList;
    // Restart the force layout.
    force.nodes(nodes)
         .links(links)
         .start();

    var minTime = d3.min(linkList, function(d) { return d.time/ divisor; })-10;
    var maxTime = d3.max(linkList, function(d) { return d.time/ divisor; })+10;

    var filteredLinks = crossfilter(linkList);
    var all = filteredLinks.groupAll(),
        time = filteredLinks.dimension(function(d) { return d.time / divisor; }),
        times = time.group();

    var charts = [
        barChart().dimension(time)
                  .group(times)
                  .x(d3.scale.linear()
                             .domain([minTime, maxTime])
                             .rangeRound([0, 40 * 20])),
    ];

    var chart = d3.selectAll(".chart")
                  .data(charts)
                  .each(function(chart) { chart.on("brush", renderAll)
                                               .on("brushend", renderAll); });

    var graph = d3.selectAll("svg")
                  .data([linkGraph]);

    d3.selectAll("#total").text(formatNumber(all.value()));

    renderAll();

    window.filter = function(filters) {
        filters.forEach(function(d, i) { charts[i].filter(d); });
        renderAll();
    };

    window.reset = function(i) {
        charts[i].filter(null);
        renderAll();
    };

    // Renders the specified chart or list.
    function render(method) {
        d3.select(this).call(method);
    }

    // Whenever the brush moves, re-rendering everything.
    function renderAll() {
        chart.each(render);
        graph.each(render);
        d3.select("#active").text(formatNumber(all.value()));
    }

    function linkGraph(div) {
        var activeLinks = time.top(Infinity);
        var userSet = {};
        activeLinks.forEach(function(d, i) {
            userSet[d.source.index] = true;
            userSet[d.target.index] = true;
        });
        var activeNodes = [];
        for (activeNodeIndex in userSet)
            activeNodes.push(nodes[activeNodeIndex]);

        // Update the links…
        link = vis.selectAll("line.link")
                  .data(activeLinks, function(d) { return d.target.id; });

        // Enter any new links.
        link.enter().insert("svg:line", ".node")
            .attr("class", "link")
            .attr("x1", function(d) { return d.source.x; })
            .attr("y1", function(d) { return d.source.y; })
            .attr("x2", function(d) { return d.target.x; })
            .attr("y2", function(d) { return d.target.y; });

        // Exit any old links.
        link.exit().remove();

        // Update the nodes…
        node = vis.selectAll("circle.node")
                  .data(activeNodes, function(d) { return d.id; })
                  .style("fill", "#fd8d3c");

        node.transition()
            .attr("r", function(d) { return Math.sqrt(d.value); });

        // Enter any new nodes.
        node.enter().append("svg:circle")
            .attr("class", "node")
            .attr("cx", function(d) { return d.x; })
            .attr("cy", function(d) { return d.y; })
            .attr("r", function(d) { return Math.sqrt(d.value); })
            .style("fill", "#fd8d3c")
            .call(force.drag);

        node.append("title")
            .text(function(d) { return d.key + ": " + d.value + " retweets."; } );

        // Exit any old nodes.
        node.exit().remove();
    }
}

function tick() {
  link.attr("x1", function(d) { return d.source.x; })
      .attr("y1", function(d) { return d.source.y; })
      .attr("x2", function(d) { return d.target.x; })
      .attr("y2", function(d) { return d.target.y; });

  node.attr("cx", function(d) { return d.x; })
      .attr("cy", function(d) { return d.y; });
}

setupControl("sports", reload);
reload();
