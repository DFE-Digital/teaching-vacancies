export const isActive = (threshold, currentInput) => currentInput ? currentInput.length >= threshold : false;

export const renderAutocomplete = (renderOptions, isFirstRender) => {
    const { currentRefinement, widgetParams } = renderOptions;

    if (isFirstRender) {
        create(widgetParams.container, widgetParams.input, widgetParams.onSelection);
    }

    const handleFocus = e => {
        widgetParams.input.value = e.target.innerHTML;
        widgetParams.onSelection(e.target.innerHTML);
    };

    if (isActive(widgetParams.threshold, currentRefinement)) {
        const options = getOptions(widgetParams.dataset, currentRefinement);

        widgetParams.container.querySelector('ul').innerHTML = options.map(renderIndexListItem).join('');

        show(widgetParams.container.querySelector('ul'), widgetParams.input);

        Array.from(widgetParams.container.querySelectorAll('.app-site-search__option'))
            .forEach(element => element.addEventListener('focus', (e) => handleFocus(e), true));
    } else {
        hide(widgetParams.container.querySelector('ul'), widgetParams.input);
    }
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

export const create = (container, input, onSelect) => {
    const ul = document.createElement('ul');
    ul.setAttribute('id', 'location__listbox');
    ul.setAttribute('role', 'listbox');
    ul.setAttribute('tabindex', 0);

    ul.classList.add('app-site-search__menu');
    ul.classList.add('app-site-search__menu--overlay');

    container.appendChild(ul);

    document.addEventListener('click', () => {
        hide(ul, input);
    });

    ul.addEventListener('click', (e) => {
        onSelect(e.target.innerHTML);
    });
}

export const getOptions = (dataset, query) => dataset.filter((result) => result.toLowerCase().indexOf(query) >= 0);

export const renderIndexListItem = (hit, index, options) => `<li class="app-site-search__option" id="app-site-search__input__option--${index}" role="option" tabindex="${index}" aria-setsize="${options.length + 1}" aria-posinset=${index}>${hit}</li>`;
