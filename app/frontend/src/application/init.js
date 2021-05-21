import ClipboardJS from 'clipboard';
import './jobseekers/init';
import './publishers/init';
import '../components/form/form';

document.addEventListener('DOMContentLoaded', () => {
  // lint disabled as would require changes to library script
  new ClipboardJS('.copy-to-clipboard'); // eslint-disable-line

  Array.from(document.getElementsByClassName('copy-to-clipboard')).forEach((el) => {
    el.addEventListener('click', (e) => {
      e.preventDefault();
    });
  });
});
