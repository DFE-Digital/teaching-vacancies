import '../../lib/after.polyfill';

export const isActive = (threshold, currentInput) => currentInput ? currentInput.length >= threshold : false;

export const renderAutocomplete = (renderOptions) => {
    const {  widgetParams } = renderOptions;

    if (!widgetParams.container.querySelector('ul')) {
        create(widgetParams.input, widgetParams.onSelection);
    }

    const handleFocus = e => {
        widgetParams.input.value = e.target.dataset.location;
        widgetParams.onSelection(e.target.dataset.location);
    };

    widgetParams.input.addEventListener('input', () => {
        const options = getOptions(widgetParams.dataset, widgetParams.input.value);
        if (isActive(widgetParams.threshold, widgetParams.input.value)) {

            widgetParams.container.querySelector('ul').innerHTML = options.map(renderIndexListItem(widgetParams.input.value)).join('');

            show(widgetParams.container.querySelector('ul'), widgetParams.input);

            Array.from(widgetParams.container.querySelectorAll('.app-site-search__option'))
                .forEach(element => element.addEventListener('focus', (e) => handleFocus(e), true));

        } else {
            hide(widgetParams.container.querySelector('ul'), widgetParams.input);
        }
    });
};

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

export const getOptions = (dataset, query) => dataset.filter((result) => result.toLowerCase().indexOf(query) >= 0);

export const renderIndexListItem = (refinement) => {
    return (hit, index, options) => `<li class="app-site-search__option" id="app-site-search__input__option--${index}" role="option" tabindex="${index}" aria-setsize="${options.length + 1}" aria-posinset=${index} data-location="${hit.toLowerCase()}">${highlightRefinement(hit, refinement)}</li>`;
    };

export const highlightRefinement = (text, refinement) => {
    const index = text.toLowerCase().indexOf(refinement);

    if (index >= 0) {
        return `${text.substring(0, index).toLowerCase()}
<span class='highlight'>
${text.toLowerCase().substring(index, index + refinement.length)}
</span>
<span>
${text.toLowerCase().substring(index + refinement.length, text.length)}
</span>
`;
    }
};
