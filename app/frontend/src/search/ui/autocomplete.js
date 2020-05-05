export const isActive = (threshold, currentInput) => currentInput ? currentInput.length >= threshold : false;

export const renderAutocomplete = (renderOptions, isFirstRender) => {
    const { currentRefinement, widgetParams } = renderOptions;

    if (isFirstRender) {
        const ul = document.createElement('ul');

        ul.classList.add('app-site-search__menu');

        widgetParams.container.appendChild(ul);

        document.addEventListener('click', () => hide(ul));

        widgetParams.container.querySelector('ul').addEventListener('click', (e) => {
            widgetParams.onSelection(e.target.innerHTML);
        });
    }

    show(widgetParams.container.querySelector('.app-site-search__menu'));

    if (isActive(widgetParams.threshold, currentRefinement)) {
        widgetParams.container.querySelector('ul').innerHTML = getOptions(widgetParams.dataset, currentRefinement)
        .map(renderIndexListItem)
        .join('');
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

export const renderIndexListItem = hit => `<li class="app-site-search__option">${hit}</li>`;
