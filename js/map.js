var mapData = { // http://www.unc.edu/~rowlett/units/codes/country.htm
    "labels": {
	"GB": "Born here, and have lived here most of my life",
	"US": "Lived here for ~5 years as a child"
    },
    "visited": { // 1-5
	// 1 ~a day
	// 3 ~3 weeks
	// 5 ~a year
	"BE": 1,
	"CA": 1,
	"CN": 3,
	"DE": 2,
	"ES": 2,
	"FR": 3,
	"GB": 5,
	"IT": 2,
	"PL": 1,
	"US": 5
    },
    "wishlist": { // 1-5
	"CH": 3,
	"CN": 3,
	"DE": 4,
	"FR": 5,
	"IN": 5,
	"JP": 4,
	"NO": 1,
	"RU": 3,
	"TH": 3,
	"ZA": 2
    },
};


$(function(){
    $(".world-map").vectorMap({
	map: 'world_mill_en',
	backgroundColor: 'white',
	zoomOnScroll: false,
	onRegionLabelShow: function(event, label, code){
	    var info = [];
	    if (code in mapData["visited"])
		info.push("(visited [" + mapData["visited"][code] + "])");
	    if (code in mapData["wishlist"])
		info.push("(wish list [" + mapData["wishlist"][code] + "])");
	    if (code in mapData["labels"])
		info.push(mapData["labels"][code])
	    // make name bold
	    label.html("<strong>" + label.html() + "</strong>");
	    // possibly change label
	    if (info) {
		label.html(label.html() +
			   "<br />" + 
			   info.join("<br />"));
	    }
	},
	regionStyle: {
	    initial: {
		fill: '#222'
	    }},
	series: {
	    // order matters: prefer visited
	    regions: [{
		values: mapData["wishlist"],
		scale: ['#90DDAF', '#167A3E'],
		normalizeFunction: 'polynomial',
		min: 1,
		max: 5
	    },
            {
		values: mapData["visited"],
		scale: ['#C8EEFF', '#0071A4'],
		normalizeFunction: 'polynomial',
		min: 1,
		max: 5
	    }]
	}});
    // delete map zoom controls
    $(".world-map .jvectormap-zoomin").remove()
    $(".world-map .jvectormap-zoomout").remove()
});
