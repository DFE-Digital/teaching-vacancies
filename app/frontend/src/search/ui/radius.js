import { updateUrlQueryParams } from '../utils'

export const renderRadiusSelect = (renderOptions, isFirstRender) => {
    const { query, refine, clear, isSearchStalled, widgetParams } = renderOptions;

    if (isFirstRender) {
        widgetParams.container.querySelector(widgetParams.element).addEventListener('change', event => {
            refine(event.target.value);
        });
    }

    query ? updateUrlQueryParams(widgetParams.key, query) : false
    document.querySelector('ul.vacancies').style.display = query ? 'none' : 'block';
    document.querySelector('ul.pagination-server').style.display = query ? 'none' : 'block';
    // widgetParams.container.querySelector('span').hidden = !isSearchStalled;
};