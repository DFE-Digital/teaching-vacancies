export const renderSearchBox = (renderOptions, isFirstRender) => {
    const { refine, widgetParams } = renderOptions;

    if (isFirstRender) {
        widgetParams.container.querySelector(widgetParams.element).addEventListener('input', event => {
            refine(event.target.value);
        });
    }
};
