import '../polyfill/after.polyfill';

export const create = (container, input, onSelect) => {
    if (!getRenderedList(container)) {
        const ul = document.createElement('ul');
        ul.setAttribute('id', 'location__listbox');
        ul.setAttribute('role', 'listbox');
        ul.setAttribute('tabindex', 0);

        ul.classList.add('app-site-search__menu');
        ul.classList.add('app-site-search__menu--overlay');

        input.after(ul);

        document.addEventListener('click', () => {
            hide(container, input);
        });

        ul.addEventListener('click', (e) => {
            onSelect(e.target.dataset.location);
        });

        input.addEventListener('keyup', e => {
            e.stopImmediatePropagation();
    
            switch (e.code) {
                case 'ArrowDown':
                    focus(container, 'next', input);
                    break;
                case 'ArrowUp':
                    focus(container, 'previous', input);
                    break;
            }
        });
    }
};

export const show = (options, container, input) => {

    render(options, container, input);

    getRenderedList(container).classList.add('app-site-search__menu--visible');
    getRenderedList(container).classList.remove('app-site-search__menu--hidden');
    input.setAttribute('aria-expanded', true);

    Array.from(getCurrentOptionElementsArray(container))
        .forEach(element => element.addEventListener('focus', (e) => input.value = e.target.dataset.location, true));
};

export const hide = (container, input) => {
    getRenderedList(container).classList.add('app-site-search__menu--hidden');
    getRenderedList(container).classList.remove('app-site-search__menu--visible');
    input.setAttribute('aria-expanded', false);
};

export const render = (options, container, input) => {
    container.querySelector('ul').innerHTML = options.map(getOptionHtml(input.value)).join('');
}

export const getRenderedList = container => container.querySelector('ul');

export const isPopulated = container => getCurrentOptionElementsArray(container).length;

export const focus = (container, direction, input) => {
    if (isPopulated(container)) {
        const elements = getFocusableOptions(container);
        elements.current && elements.current.classList.remove('app-site-search__option--focused');
        elements[direction] && elements[direction].classList.add('app-site-search__option--focused');
        input.value = elements[direction] ? elements[direction].dataset.location : '';
    }
};

export const getCurrentOptionElementsArray = container => container.querySelectorAll('.app-site-search__option');

export const getFocusableOptions = container => {

    const next = getFocusedOption(container) ? getOptionIndex(getFocusedOption(container)) + 1 : 0;
    const previous = getFocusedOption(container) ? getOptionIndex(getFocusedOption(container)) - 1 : 0;

    return {
        next: container.querySelector(`#app-site-search__input__option--${next}`),
        previous: container.querySelector(`#app-site-search__input__option--${previous}`),
        current: getFocusedOption(container),
    };
};

export const getOptionIndex = el => parseInt(el.getAttribute('aria-posinset'), 10);

export const getFocusedOption = container => container.getElementsByClassName('app-site-search__option--focused')[0];

export const getOptionHtml = (refinement) => {
    return (hit, index, options) => `<li class="app-site-search__option" id="app-site-search__input__option--${index}" role="option" tabindex="${index}" aria-setsize="${options.length + 1}" aria-posinset=${index} data-location="${hit.toLowerCase()}">${highlightRefinement(hit, refinement)}</li>`;
};

export const highlightRefinement = (text, refinement) => {
    
    const index = text.toLowerCase().indexOf(refinement.toLowerCase());

    if (index >= 0) {
        return `${text.substring(0, index)}
<span class='highlight'>${text.substring(index, index + refinement.length)}</span>
<span>${text.substring(index + refinement.length, text.length)}</span>
`;
    }
};