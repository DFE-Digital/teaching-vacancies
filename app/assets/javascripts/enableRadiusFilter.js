$(document).ready(function() {
  if ($("#radius").is(":disabled")) {
    $("#location").click(function() {
      $("#radius").prop("disabled", false);
    });
  }
});
