function parseTime(t) {
    return new Date(parseInt(t)*1000);
}

function activeLabel(controlGroup) {
    return d3.selectAll("#" + controlGroup).select(".active").attr("id");
}

function activate(group, link) {
    d3.selectAll("#" + group + " a").attr("class", "inactive");
    d3.select("#" + group + " #" + link).attr("class", "active");
}

function setupControl(divName, callback) {
    d3.selectAll("#" + divName + " a").on("click", function (d) {
        var newItem = d3.select(this).attr("id");
        activate(divName, newItem);
        if (callback)
            callback();
    });
}
