import ClipboardJS from 'clipboard';
import './jobseekers/init';
import './publishers/init';
import '../components/form/form';

document.addEventListener('DOMContentLoaded', () => {
  window.dataLayer = window.dataLayer || [];
  dataLayer.push({ event: 'optimize.activate' });

  dataLayer.push({
    dePIIedURL: window.location.pathname,
    event: 'parametersRemoved',
  });

  // will check with steven legg about this as if needs it need to add tests around it
  const element = document.querySelector('.new_copy_vacancy_form') || document.body || {};
  const dataset = element.dataset || {};
  dataLayer.push({ vacancy_state: dataset.vacancyState });

  // lint disabled as would require changes to library script
  new ClipboardJS('.copy-to-clipboard'); // eslint-disable-line

  Array.from(document.getElementsByClassName('copy-to-clipboard')).forEach((el) => {
    el.addEventListener('click', (e) => {
      e.preventDefault();
    });
  });
});
