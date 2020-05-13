export const isActive = (threshold, currentInput) => currentInput ? currentInput.length >= threshold : false;

export const renderAutocomplete = (renderOptions, isFirstRender) => {
    const { currentRefinement, widgetParams } = renderOptions;

    if (isFirstRender) {
        const ul = document.createElement('ul');
        ul.setAttribute('id', 'location__listbox');
        ul.setAttribute('role', 'listbox');
        ul.setAttribute('tabindex', 0);

        ul.classList.add('app-site-search__menu');
        ul.classList.add('app-site-search__menu--overlay');

        widgetParams.container.appendChild(ul);

        document.addEventListener('click', () => {
            hide(ul);
            widgetParams.input.setAttribute('aria-expanded', false);
        });

        ul.addEventListener('click', (e) => {
            widgetParams.onSelection(e.target.innerHTML);
        });
    }

    const handleFocus = (e) => {
        widgetParams.input.value = e.target.innerHTML;
        widgetParams.onSelection(e.target.innerHTML);
    };

    show(widgetParams.container.querySelector('.app-site-search__menu'));

    if (isActive(widgetParams.threshold, currentRefinement)) {
        const options = getOptions(widgetParams.dataset, currentRefinement);
        const active = options.length ? true : false;

        widgetParams.input.setAttribute('aria-expanded', active);

        widgetParams.container.querySelector('ul').innerHTML = options.map(renderIndexListItem).join('');

        Array.from(widgetParams.container.querySelectorAll('.app-site-search__option'))
            .forEach(element => element.addEventListener('focus', (e) => handleFocus(e), true));
    }
};

export const show = element => {
    element.classList.add('app-site-search__menu--visible');
    element.classList.remove('app-site-search__menu--hidden');
};

export const hide = element => {
    element.classList.add('app-site-search__menu--hidden');
    element.classList.remove('app-site-search__menu--visible');
};

export const getOptions = (dataset, query) => dataset.filter((result) => result.toLowerCase().indexOf(query) >= 0);

export const renderIndexListItem = (hit, index, options) => `<li class="app-site-search__option" id="app-site-search__input__option--${index}" role="option" tabindex="${index}" aria-setsize="${options.length + 1}" aria-posinset=${index}>${hit}</li>`;
