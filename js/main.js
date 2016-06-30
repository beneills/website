// this script requires jQuery
$(document).ready(function() {
    var time = Math.ceil(($(".reading-text").text().length/5)/200);
    var units = time == 1 ? "min" : "mins";
    $("#reading-time").text(time + " " + units);

    new ShareButton({
      ui: {
        buttonText: 'share this page'
      }
    });
});

// // Beeminder Image Fade
// window.handleBeeminderImageLoad = function(obj) {
//     $(obj).fadeIn(10000);
// }​

window.handleBeeminderImageLoad = function(obj) {
    $(obj).fadeIn(500);
};
