// this script requires jQuery
$(document).ready(function() {
    Footnotes.setup();
    //Footnotes.add($('#aboutnote'), 'test text'); // TODO
});

var Footnotes = {
    footnotetimeout: false,
    setup: function() {
        var footnotelinks = $("a[rel='footnote']")

        footnotelinks.unbind('mouseover',Footnotes.footnoteover);
        footnotelinks.unbind('mouseout',Footnotes.footnoteoout);
        
        footnotelinks.bind('mouseover',Footnotes.footnoteover);
        footnotelinks.bind('mouseout',Footnotes.footnoteoout);
    },

    add: function(element, html) {
	element.unbind('mouseover', function(s) { Footnotes.footnoteover(s, html); });
        element.unbind('mouseout',Footnotes.footnoteoout);
        
	element.bind('mouseover', function(s) { Footnotes.footnoteover(s, html); });
        element.bind('mouseout',Footnotes.footnoteoout);
    },

    drawbox: function(self, html) {
        var position = self.offset();
        var div = $(document.createElement('div'));
        div.attr('id','footnotediv');
        div.bind('mouseover',Footnotes.divover);
        div.bind('mouseout',Footnotes.footnoteoout);
        div.html(html);

        div.css({position:'absolute'});
        $(document.body).append(div);

        var left = position.left;
        if(left + 420  > $(window).width() + $(window).scrollLeft())
            left = $(window).width() - 420 + $(window).scrollLeft();
        var top = position.top+20;
        if(top + div.height() > $(window).height() + $(window).scrollTop())
            top = position.top - div.height() - 15;
        div.css({
            left:left,
            top:top
        });
    },

    footnoteover: function(self, html) {
        $('#footnotediv').stop();
        $('#footnotediv').remove();
    
	/*hack*/
	if ($(this).attr('id') == "aboutauthor") {
	    html = "about the author"
	}

	if (html == undefined) {
            var id = $(this).attr('href').substr(1);
            var el = document.getElementById(id);
	    html = $(el).html();
	}
	Footnotes.drawbox($(this), html);
    },

    footnoteoout: function() {
        Footnotes.footnotetimeout = setTimeout(function() {
            $('#footnotediv').animate({
                opacity: 0
            }, 400, function() {
                $('#footnotediv').remove();
            });
        },100);
    },
    divover: function() {
        clearTimeout(Footnotes.footnotetimeout);
        $('#footnotediv').stop();
        $('#footnotediv').css({
                opacity: 0.9
        });
    }
}
