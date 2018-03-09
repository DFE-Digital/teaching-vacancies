// Track when someone submits the search form
$(document).on('submit', 'form.filters-form', function() {
    gtag('event', 'search_form_complete');
  }
);
