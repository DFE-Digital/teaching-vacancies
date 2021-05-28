document.addEventListener('trix-initialize', (e) => {
  const inputAttribute = Array.from(e.target.attributes).filter((attr) => attr.name === 'input')[0];
  document.getElementById(inputAttribute.value).style.display = 'none';
});

document.addEventListener('trix-change', (e) => {
  const inputAttribute = Array.from(e.target.attributes).filter((attr) => attr.name === 'input')[0];
  document.getElementById(inputAttribute.value).value = e.target.editor.element.innerHTML;
});
