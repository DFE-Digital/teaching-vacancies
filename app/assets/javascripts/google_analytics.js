// Track when someone submits the search form
$(document).on('submit', 'form.filters-form', function() {
    gtag('event', 'search_form_complete');
  }
);

// Track when someone views a vacancy from a list of results
$(document).on('click', '.view-vacancy-link', function() {
    gtag('event', 'vacancy_visited');
  }
);

// Track when someone applies for a vacancy
$(document).on('click', '.vacancy-apply-link', function() {
    gtag('event', 'vacancy_applied');
  }
);

// Track when someone starts to edit their school
$(document).on('click', '.school-edit-started', function() {
    gtag('event', 'school_edit_started');
  }
);

// Track when someone submits the edit school form
$(document).on('submit', 'form.school-edit-form', function() {
    gtag('event', 'school_edit_complete');
  }
);

// Track when someone starts to create a vacancy
$(document).on('click', '.vacancy-create-button', function() {
    gtag('event', 'vacancy_creation_started');
  }
);

// Track when someone completes the first part of the vacancy form
$(document).on('submit', 'form.vacancy-job-specification-new-form', function() {
    gtag('event', 'vacancy_job_specification_created');
  }
);

// Track when someone edits the first part of the vacancy form
$(document).on('submit', 'form.vacancy-job-specification-edit-form', function() {
    gtag('event', 'vacancy_job_specification_edited');
  }
);

// Track when someone completes the second part of the vacancy form
$(document).on('submit', 'form.vacancy-candidate-specification-new-form', function() {
    gtag('event', 'vacancy_candidate_specification_created');
  }
);

// Track when someone edits the second part of the vacancy form
$(document).on('submit', 'form.vacancy-candidate-specification-edit-form', function() {
    gtag('event', 'vacancy_candidate_specification_edited');
  }
);

// Track when someone completes the third part of the vacancy form
$(document).on('submit', 'form.vacancy-application-details-new-form', function() {
    gtag('event', 'vacancy_application_details_created');
  }
);

// Track when someone edits the third part of the vacancy form
$(document).on('submit', 'form.vacancy-application-details-edit-form', function() {
    gtag('event', 'vacancy_application_details_edited');
  }
);

// Track when someone starts to create a vacancy
$(document).on('click', '.vacancy-review', function() {
    gtag('event', 'vacancy_reviewed');
  }
);
