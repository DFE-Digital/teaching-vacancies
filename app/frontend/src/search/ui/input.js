export const renderSearchBox = (renderOptions, isFirstRender) => {
    const { refine, widgetParams } = renderOptions;

    if (isFirstRender) {

        document.querySelector('#location-radius-select').style.display = 'none';

        if (getSearchInputValues().filter(value => value.length).length) {
            refine(getSearchInputValues().filter(value => value.length).join(' '));
        }

        widgetParams.container.querySelector(widgetParams.element).addEventListener('input', () => {
            refine(getSearchInputValues().filter(value => value.length).join(' '));
        });

        widgetParams.container.querySelector(widgetParams.element).addEventListener('change', () => {
            refine(getSearchInputValues().filter(value => value.length).join(' '));
        });
    }
};

export const getSearchInputValues = () => [
    document.querySelector('#keyword').value,
    document.querySelector('#location').value
];
