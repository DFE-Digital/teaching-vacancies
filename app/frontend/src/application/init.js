/* eslint-disable */
const google_optimize_activate = function () {
  window.dataLayer = window.dataLayer || [];
  dataLayer.push({ event: 'optimize.activate' });
};

$(document).ready(google_optimize_activate);

google_optimize_activate();

/* eslint-disable */
document.addEventListener('DOMContentLoaded', (event) => {
  dataLayer.push({
    dePIIedURL: window.location.pathname,
    event: 'parametersRemoved',
  });
});
