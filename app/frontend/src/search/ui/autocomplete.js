import '../../lib/after.polyfill';

export const isActive = (threshold, currentInput) => currentInput ? currentInput.length >= threshold : false;

export const renderAutocomplete = (renderOptions) => {
    const { widgetParams } = renderOptions;

    if (!widgetParams.container.querySelector('ul')) {
        create(widgetParams.input, widgetParams.onSelection);
    }

    const handleSelection = e => {
        widgetParams.input.value = e.target.dataset.location;
    };

    widgetParams.input.addEventListener('input', () => {
        const options = getOptions(widgetParams.dataset, widgetParams.input.value);
        if (isActive(widgetParams.threshold, widgetParams.input.value)) {

            widgetParams.container.querySelector('ul').innerHTML = options.map(renderIndexListItem(widgetParams.input.value)).join('');

            show(widgetParams.container.querySelector('ul'), widgetParams.input);

            Array.from(widgetParams.container.querySelectorAll('.app-site-search__option'))
                .forEach(element => element.addEventListener('focus', (e) => handleSelection(e), true));

        } else {
            hide(widgetParams.container.querySelector('ul'), widgetParams.input);
        }
    });

    widgetParams.input.addEventListener('keyup', e => {
        e.stopImmediatePropagation();

        switch (e.code) {
            case 'ArrowDown':
                focusElement('next', widgetParams.input);
                break;
            case 'ArrowUp':
                focusElement('previous', widgetParams.input);
                break;
        }
    });
};

export const getFocusedElement = () => document.getElementsByClassName('app-site-search__option--focused')[0];

export const focusElement = (direction, input) => {
    if (isPopulated()) {
        const elements = getFocusableElement(direction);
        elements.current && elements.current.classList.remove('app-site-search__option--focused');
        elements[direction] && elements[direction].classList.add('app-site-search__option--focused');
        input.value = elements[direction] ? elements[direction].dataset.location : '';
    }
};

export const getCurrentOptionElementsArray = () => document.getElementsByClassName('app-site-search__option');

export const isPopulated = () => getCurrentOptionElementsArray().length;

export const getFocusableElement = () => {
    const next = getFocusedElement() ? getOptionIndex(getFocusedElement()) + 1 : 0;
    const previous = getFocusedElement() ? getOptionIndex(getFocusedElement()) - 1 : 0;
    return {
        next: document.getElementById(`app-site-search__input__option--${next}`),
        previous: document.getElementById(`app-site-search__input__option--${previous}`),
        current: getFocusedElement(),
    };
};

export const getOptionIndex = el => parseInt(el.getAttribute('aria-posinset'), 10);

export const show = (element, inputElement) => {
    element.classList.add('app-site-search__menu--visible');
    element.classList.remove('app-site-search__menu--hidden');
    inputElement.setAttribute('aria-expanded', true);
};

export const hide = (element, inputElement) => {
    element.classList.add('app-site-search__menu--hidden');
    element.classList.remove('app-site-search__menu--visible');
    inputElement.setAttribute('aria-expanded', false);
};

export const create = (input, onSelect) => {
    const ul = document.createElement('ul');
    ul.setAttribute('id', 'location__listbox');
    ul.setAttribute('role', 'listbox');
    ul.setAttribute('tabindex', 0);

    ul.classList.add('app-site-search__menu');
    ul.classList.add('app-site-search__menu--overlay');

    input.after(ul);

    document.addEventListener('click', () => {
        hide(ul, input);
    });

    ul.addEventListener('click', (e) => {
        onSelect(e.target.dataset.location);
    });
};

export const getOptions = (dataset, query) => dataset.filter((option) => option.toLowerCase().indexOf(query.toLowerCase()) >= 0);

export const renderIndexListItem = (refinement) => {
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
