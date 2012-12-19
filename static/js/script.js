
$(document).ready(function(){
    initSlidingMenu();
    initLogBox();
});

/* Initialize sliding menu features */
initSlidingMenu = function() {
    $(".LeftMenuHeading").mouseenter(function(event){
	/* Just show this one */
	/* Chain stop() to prevent animation queue buildup */
	$(this).children(".LeftSubMenu").stop().slideDown(300);

	/* Modify navigation menu position so that curson is over first item */
	var left_menu = $("#LeftMenu");
	var current_margin = left_menu.css("margin-top");
	var num_children = $(this).find("ul > li").length;
	var new_margin = Math.max(0, event.pageY - left_menu.offset().top - ($(this).index()-0.5+num_children)*52);
	/* Chain stop() to prevent animation queue buildup */
	left_menu.stop().animate({"margin-top": new_margin+"px"}, 300);	
    });

    $(".LeftMenuHeading").mouseleave(function(){	
	/* Stop all other sliding */
	$(this).stop(true);
	/* And just hide this one */
	/* Chain stop() to prevent animation queue buildup */
	$(this).children(".LeftSubMenu").stop().slideUp(300);
    });

    $("#LeftContent").mouseleave(function(){
	/* Reset navigation menu position */
	/* Chain stop() to prevent animation queue buildup */
	$("#LeftMenu").stop().animate({"margin-top": "0"}, 500);
    });
};

/* Initialize log box expansion feature */
initLogBox = function() {
    $("#MoreLog").click(function(){
	/* Replace "more" with "full" */
	$("#MoreLog").fadeOut(200, function(){
	    $("#FullLog").fadeIn(200);
	});

	/* Slide down additional items */
	$("#LogItemsNext").slideDown(300);
    });
};
