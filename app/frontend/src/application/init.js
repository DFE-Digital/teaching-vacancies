import './search/init';
import './hiring_staff/init';

document.addEventListener('DOMContentLoaded', () => {
  window.dataLayer = window.dataLayer || [];
  dataLayer.push({ event: 'optimize.activate' });

  dataLayer.push({
    dePIIedURL: window.location.pathname,
    event: 'parametersRemoved',
  });
});
