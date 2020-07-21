/* eslint-disable */
document.addEventListener('DOMContentLoaded', (event) => {
  dataLayer.push({
    dePIIedURL: window.location.pathname,
    event: 'parametersRemoved',
  });
});
