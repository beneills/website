// this script requires jQuery
$(document).ready(function() {
    var time = Math.ceil(($(".markdown-body").text().length/5)/200);
    var units = time == 1 ? "min" : "mins";
    $("#reading-time").text(time + " " + units);
});

// // Beeminder Image Fade
// window.handleBeeminderImageLoad = function(obj) {
//     $(obj).fadeIn(10000);
// }​

window.handleBeeminderImageLoad = function(obj) {
    $(obj).fadeIn(500);
};


