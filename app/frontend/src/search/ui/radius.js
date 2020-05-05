import { updateUrlQueryParams } from '../utils';

export const renderRadiusSelect = (renderOptions, isFirstRender) => {
    const { query, widgetParams } = renderOptions;

    if (isFirstRender) {
        widgetParams.container.querySelector(widgetParams.element).addEventListener('change', event => {
            widgetParams.onSelection(event.target.value);
        });

        widgetParams.container.querySelector(widgetParams.element).setAttribute('disabled', true);
    }

    query ? updateUrlQueryParams(widgetParams.key, query) : false;
};
