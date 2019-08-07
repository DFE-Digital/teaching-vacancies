var google_optimize_activate = function() {
  dataLayer.push({'event': 'optimize.activate'});
};

$(document).on("turbolinks:visit", google_optimize_activate);

google_optimize_activate();