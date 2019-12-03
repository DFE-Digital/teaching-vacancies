$(document).on("turbolinks:load", function() {
  if ($("#radius").is(":disabled")) {
    $("#location").click(function() {
      $("#radius").prop("disabled", false);
    });
  }
});
