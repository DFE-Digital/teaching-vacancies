import { updateUrlQueryParams } from '../../lib/utils';

export const renderRadiusSelect = (renderOptions, isFirstRender) => {
    const { query, widgetParams } = renderOptions;

    if (isFirstRender) {
        widgetParams.inputElement.addEventListener('change', event => {
            widgetParams.onSelection(event.target.value);
        });
        disableRadiusSelect();
    }

    query ? updateUrlQueryParams(widgetParams.key, query) : false;
};

export const enableRadiusSelect = () => {

    if (document.querySelector('#radius')) {
        document.querySelector('#radius').removeAttribute('disabled');
    }

    if (document.querySelector('#location-radius-select')) {
        document.querySelector('#location-radius-select').style.display = 'block';
    }
};

export const disableRadiusSelect = () => {
    if (document.querySelector('#radius')) {
        document.querySelector('#radius').disabled = true;
    }

    if (document.querySelector('#location-radius-select')) {
        document.querySelector('#location-radius-select').style.display = 'none';
    }
};
