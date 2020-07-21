/* eslint-disable */
$(document).on('click', '.govuk-back-link.with-referrer', (event) => {
  history.back();
  event.preventDefault();
});
