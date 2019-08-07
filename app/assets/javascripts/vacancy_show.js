$(document).on('click', '.govuk-back-link.with-referrer', function(event) {
  history.back();
  event.preventDefault();
});