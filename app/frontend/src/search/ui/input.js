export const renderSearchBox = (renderOptions, isFirstRender) => {
    const { refine, widgetParams } = renderOptions;

    if (isFirstRender) {

        document.querySelector('#location-radius-select').style.display = 'none';

        if (getSearchInputValues().filter(value => value).length) {
            refine(getSearchInputValues().filter(value => value.length).join(' '));
        }

        widgetParams.inputElement.addEventListener('input', () => {
            enableSubmitButton(widgetParams.container);
            widgetParams.inputElement.dataset.searchTerm = widgetParams.inputElement.value;
        });

        widgetParams.inputElement.addEventListener('change', () => {
            enableSubmitButton(widgetParams.container);
            widgetParams.inputElement.dataset.searchTerm = widgetParams.inputElement.value;
        });

        widgetParams.container.addEventListener('submit', (e) => {
            e.preventDefault();
            widgetParams.inputElement.dataset.searchTerm = widgetParams.inputElement.value;
            refine(getSearchInputValues().filter(value => value).join(' '));
        });
    }
};

export const enableSubmitButton = container => container.querySelector('input[type="submit"]').disabled = false;

export const getSearchInputValues = () => [
    document.querySelector('#keyword').dataset.searchTerm,
    document.querySelector('#location').dataset.searchTerm
];
