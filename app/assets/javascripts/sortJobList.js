$(document).on("turbolinks:load", function() {
  $("#jobs_sort").change(function() {
    this.form.submit();
  });
  $("#submit_job_sort").hide();
});
