$(document).on("turbolinks:load", function() {
  $("#jobs_sort").change(function() {
    this.form.submit();
  });
  $("input[data-disable-with=Sort]").hide();
});
