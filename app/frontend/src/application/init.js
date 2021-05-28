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

document.addEventListener('trix-initialize', (e) => {
  const eid = Array.from(e.target.attributes).find((attr) => attr.name === 'input');
  document.getElementById(eid.value).style.display = 'none';
});

document.addEventListener('trix-change', (e) => {
  const eid = Array.from(e.target.attributes).find((attr) => attr.name === 'input');
  document.getElementById(eid.value).value = e.target.editor.element.innerHTML;
});
