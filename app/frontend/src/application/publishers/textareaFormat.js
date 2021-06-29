const ERROR_CLASS_POSTFIX = '-error';

document.addEventListener('trix-initialize', (e) => {
  const inputAttribute = Array.from(e.target.attributes).filter((attr) => attr.name === 'input')[0];

  if (document.getElementById(inputAttribute.value)) {
    document.getElementById(inputAttribute.value).style.display = 'none';
  }

  if (document.getElementById(`${inputAttribute.value}${ERROR_CLASS_POSTFIX}`)) {
    document.getElementById(`${inputAttribute.value}${ERROR_CLASS_POSTFIX}`).style.display = 'none';
    e.target.parentElement.classList.add('govuk-form-group--error');
  }
});

document.addEventListener('trix-change', (e) => {
  const inputAttribute = Array.from(e.target.attributes).filter((attr) => attr.name === 'input')[0];

  if (document.getElementById(inputAttribute.value)) {
    document.getElementById(inputAttribute.value).value = e.target.editor.element.innerHTML;
  }

  if (document.getElementById(`${inputAttribute.value}${ERROR_CLASS_POSTFIX}`)) {
    document.getElementById(`${inputAttribute.value}${ERROR_CLASS_POSTFIX}`).value = e.target.editor.element.innerHTML;
  }
});
