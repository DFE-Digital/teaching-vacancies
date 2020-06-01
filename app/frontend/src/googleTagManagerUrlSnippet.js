document.addEventListener("DOMContentLoaded", function(event) {
  dataLayer.push({
    dePIIedURL: window.location.pathname,
    event: "parametersRemoved"
  });
});
