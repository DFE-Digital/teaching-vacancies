import logger from '../../lib/logging';

document.addEventListener('trix-initialize', (e) => {
  const inputAttribute = Array.from(e.target.attributes).filter((attr) => attr.name === 'input')[0];

  try {
    document.getElementById(inputAttribute.value).style.display = 'none';
  } catch (error) {
    logger.warn(`[component: textarea formatting init] ${error.message} input: ${inputAttribute}`);
  }
});

document.addEventListener('trix-change', (e) => {
  const inputAttribute = Array.from(e.target.attributes).filter((attr) => attr.name === 'input')[0];

  try {
    document.getElementById(inputAttribute.value).value = e.target.editor.element.innerHTML;
  } catch (error) {
    logger.warn(`[component: textarea formatting change] ${error.message} input: ${inputAttribute}`);
  }
});
