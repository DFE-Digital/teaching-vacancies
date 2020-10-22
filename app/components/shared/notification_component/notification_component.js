/* eslint-disable */
$(document).on('click', '.js-dismissable__link', function (e) {
  e.preventDefault();
  $(this).closest('.js-dismissable').fadeOut();
});