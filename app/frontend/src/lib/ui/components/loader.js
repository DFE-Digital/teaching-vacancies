import '../../polyfill/remove.polyfill';

export const add = (targetEl, placeholder) => {
  targetEl.insertAdjacentHTML('afterend', loaderSvg);
  targetEl.style.padding = '5px 5px 5px 36px';
  targetEl.placeholder = placeholder;
};

export const remove = (targetEl, placeholder) => {
  const loader = document.getElementById('loader');
  targetEl.style.padding = '5px';
  loader.remove();
  targetEl.setAttribute('placeholder', placeholder);
};

const loaderSvg = `<svg version="1.1" xmlns="http://www.w3.org/2000/svg" class="govuk-c-loader__spinner" id="loader" width="32" height="32" viewBox="-32 -32 64 64" preserveAspectRatio="xMidYMid meet">
<rect fill="#000" width="12" height="5" rx="2.5" ry="2.5" transform="rotate(0, 0, 2) translate(10 0)" opacity="0.25"></rect>
<rect fill="#000" width="12" height="5" rx="2.5" ry="2.5" transform="rotate(30, 0, 2) translate(10 0)" opacity="0.25"></rect>
<rect fill="#000" width="12" height="5" rx="2.5" ry="2.5" transform="rotate(60, 0, 2) translate(10 0)" opacity="0.25"></rect>
<rect fill="#000" width="12" height="5" rx="2.5" ry="2.5" transform="rotate(90, 0, 2) translate(10 0)" opacity="0.25"></rect>
<rect fill="#000" width="12" height="5" rx="2.5" ry="2.5" transform="rotate(120, 0, 2) translate(10 0)" opacity="0.25"></rect>
<rect fill="#000" width="12" height="5" rx="2.5" ry="2.5" transform="rotate(150, 0, 2) translate(10 0)" opacity="0.25"></rect>
<rect fill="#000" width="12" height="5" rx="2.5" ry="2.5" transform="rotate(180, 0, 2) translate(10 0)" opacity="0.25"></rect>
<rect fill="#000" width="12" height="5" rx="2.5" ry="2.5" transform="rotate(210, 0, 2) translate(10 0)" opacity="0.25"></rect>
<rect fill="#000" width="12" height="5" rx="2.5" ry="2.5" transform="rotate(240, 0, 2) translate(10 0)" opacity="0.25"></rect>
<rect fill="#000" width="12" height="5" rx="2.5" ry="2.5" transform="rotate(270, 0, 2) translate(10 0)" opacity="0.25"></rect>
<rect fill="#000" width="12" height="5" rx="2.5" ry="2.5" transform="rotate(300, 0, 2) translate(10 0)" opacity="0.25"></rect>
<rect fill="#000" width="12" height="5" rx="2.5" ry="2.5" transform="rotate(330, 0, 2) translate(10 0)" opacity="0.25"></rect>
</svg>`;

const loader = {
  add,
  remove,
};

export default loader;
