import logger from '../../lib/logging';

document.addEventListener('trix-initialize', (e) => {
  try {
    const inputAttribute = Array.from(e.target.attributes).filter((attr) => attr.name === 'input')[0];
    document.getElementById(inputAttribute.value).style.display = 'none';
  } catch (e) {
    logger.warn(`[component: textarea formatting init] ${e.message} input: ${inputAttribute}`);
  }
});

document.addEventListener('trix-change', (e) => {
  try {
    const inputAttribute = Array.from(e.target.attributes).filter((attr) => attr.name === 'input')[0];
    document.getElementById(inputAttribute.value).value = e.target.editor.element.innerHTML;
  } catch (e) {
    logger.warn(`[component: textarea formatting change] ${e.message} input: ${inputAttribute}`);
  }
});
