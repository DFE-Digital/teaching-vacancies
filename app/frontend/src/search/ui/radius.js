import { updateUrlQueryParams } from '../../lib/utils';

export const renderRadiusSelect = (renderOptions, isFirstRender) => {
  const { query, widgetParams } = renderOptions;

  if (isFirstRender) {
    widgetParams.inputElement.addEventListener('change', (event) => {
      widgetParams.onSelection(event.target.value);
    });
  }

  if (query) {
    updateUrlQueryParams(widgetParams.key, query);
  }
};

export const enableRadiusSelect = () => {
  document.querySelector('#radius').removeAttribute('disabled');
  document.querySelector('#location-radius-select').style.display = 'block';
};

export const disableRadiusSelect = () => {
  document.querySelector('#radius').disabled = true;
  document.querySelector('#location-radius-select').style.display = 'none';
};
