window.onpopstate = function(event) {
  if (event.state == null) return
  if (event.state.name == 'CustomHistoryManipulator') {
    window.location = document.location;
  }
};

$(document).on('click', '.govuk-link', function(e) {
    stateObj = { name: "CustomHistoryManipulator" }
    history.pushState(stateObj, "Custom history manipulator to fix govuk_frontend/all tabular bug with browser back on desktop", "/school");
  }
);
