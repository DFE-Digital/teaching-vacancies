import '../lib/polyfill/after.polyfill';

import { onChange as locationChange } from '../search/ui/input/location';

export const create = (container, input, key) => {
  if (!getRenderedList(container)) {
    const ul = document.createElement('ul');
    ul.setAttribute('id', `${key}__listbox`);
    ul.setAttribute('role', 'listbox');
    ul.setAttribute('aria-label', `Suggested ${key}s`);
    ul.setAttribute('tabindex', -1);

    ul.classList.add('autocomplete__menu');
    ul.classList.add('autocomplete__menu--overlay');

    input.after(ul);

    document.addEventListener('click', () => {
      autocomplete.hide(container, input);
    });

    ul.addEventListener('click', (e) => {
      setInputValue(input, e.target.dataset[key]);
      locationChange(e.target.dataset[key]);
    });

    input.addEventListener('keyup', (e) => {
      e.stopImmediatePropagation();

      switch (e.code) {
        case 'ArrowDown':
          autocomplete.focus(container, 'next', input, key);
          break;
        case 'ArrowUp':
          autocomplete.focus(container, 'previous', input, key);
          break;
        default:
          break;
      }
    });
  }
};

export const show = (options, container, input, key) => {
  autocomplete.render(options, container, input, key);

  getRenderedList(container).classList.add('autocomplete__menu--visible');
  getRenderedList(container).classList.remove('autocomplete__menu--hidden');
  input.setAttribute('aria-expanded', true);
};

export const setInputValue = (input, value) => {
  input.value = value;
};

export const hide = (container, input) => {
  getRenderedList(container).classList.add('autocomplete__menu--hidden');
  getRenderedList(container).classList.remove('autocomplete__menu--visible');
  input.setAttribute('aria-expanded', false);
};

export const render = (options = [], container, input, key) => {
  container.querySelector('ul').innerHTML = options.map(getOptionHtml(input.value, key)).join('');
};

export const getRenderedList = (container) => container.querySelector('ul');

export const isPopulated = (container) => getCurrentOptionElementsArray(container).length;

export const focus = (container, direction, input, key) => {
  if (isPopulated(container)) {
    const elements = getFocusableOptions(container);

    if (elements.current) {
      elements.current.classList.remove('autocomplete__option--focused');
    }

    if (elements[direction]) {
      elements[direction].classList.add('autocomplete__option--focused');
    }

    input.value = elements[direction] ? elements[direction].dataset[key] : '';
  }
};

export const getCurrentOptionElementsArray = (container) => container.querySelectorAll('.autocomplete__option');

export const getFocusableOptions = (container) => {
  const next = getFocusedOption(container) ? getOptionIndex(getFocusedOption(container)) + 1 : 0;
  const previous = getFocusedOption(container) ? getOptionIndex(getFocusedOption(container)) - 1 : 0;

  return {
    next: container.querySelector(`#autocomplete__input__option--${next}`),
    previous: container.querySelector(`#autocomplete__input__option--${previous}`),
    current: getFocusedOption(container),
  };
};

export const getOptionIndex = (el) => parseInt(el.getAttribute('aria-posinset'), 10);

export const getFocusedOption = (container) => container.getElementsByClassName('autocomplete__option--focused')[0];

export const getOptionHtml = (refinement, key) => (hit, index, options) => `
<li class="autocomplete__option" id="autocomplete__input__option--${index}"
role="option" tabindex="-1" aria-setsize="${options.length + 1}" aria-posinset=${index}
data-${key}="${hit}">
${highlightRefinement(hit, refinement)}
</li>`;

export const highlightRefinement = (text, refinement) => {
  const index = text.toLowerCase().indexOf(refinement.toLowerCase());

  if (index >= 0) {
    return `${text.substring(0, index)}<span class='highlight'>${text.substring(index, index + refinement.length)}</span><span>${text.substring(index + refinement.length, text.length)}</span>`;
  }

  return text;
};

const autocomplete = {
  show,
  hide,
  focus,
  create,
  render,
};

export default autocomplete;
