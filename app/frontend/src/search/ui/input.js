import { updateUrlQueryParams } from '../utils';

export const renderSearchBox = (renderOptions, isFirstRender) => {
    const { query, refine, widgetParams } = renderOptions;

    if (isFirstRender) {
        widgetParams.container.querySelector(widgetParams.element).addEventListener('input', event => {
            refine(event.target.value);
        });
    }

    query ? updateUrlQueryParams(widgetParams.key, query) : false;
    document.querySelector('ul.vacancies').style.display = query ? 'none' : 'block';
    // document.querySelector('ul.pagination-server').style.display = query ? 'none' : 'block';
};