import { updateUrlQueryParams } from '../utils';

export const renderRadiusSelect = (renderOptions, isFirstRender) => {
    const { query, widgetParams } = renderOptions;

    if (isFirstRender) {
        widgetParams.inputElement.addEventListener('change', event => {
            widgetParams.onSelection(event.target.value);
        });
    }

    query ? updateUrlQueryParams(widgetParams.key, query) : false;
};
