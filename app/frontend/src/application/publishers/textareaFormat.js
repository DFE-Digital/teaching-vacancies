document.addEventListener('trix-initialize', (e) => {
  const el = Array.from(e.target.attributes).filter((attr) => attr.name === 'input')[0];
  document.getElementById(el.value).style.display = 'none';
});

document.addEventListener('trix-change', (e) => {
  const el = Array.from(e.target.attributes).filter((attr) => attr.name === 'input')[0];
  document.getElementById(el.value).value = e.target.editor.element.innerHTML;
});
