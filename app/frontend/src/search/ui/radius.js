import { updateUrlQueryParams } from '../utils';

export const renderRadiusSelect = (renderOptions, isFirstRender) => {
    const { query, widgetParams } = renderOptions;

    if (isFirstRender) {
        widgetParams.inputElement.addEventListener('change', event => {
            widgetParams.onSelection(event.target.value);
        });

        widgetParams.inputElement.setAttribute('disabled', true);
    }

    query ? updateUrlQueryParams(widgetParams.key, query) : false;
};
