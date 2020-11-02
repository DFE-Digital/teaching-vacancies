$(document).on('click', '.js-dismissable__link', (e) => {
  e.preventDefault();
  $(this).closest('.js-dismissable').fadeOut();
});
