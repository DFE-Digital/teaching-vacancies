import { updateUrlQueryParams, convertMilesToMetres } from '../../../lib/utils';

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

export const getRadius = () => {
  if (document.querySelector('#radius') && document.querySelector('#radius').dataset.radius) {
    return convertMilesToMetres(document.querySelector('#radius').dataset.radius);
  }
  return false;
};

export const renderRadiusSelect = (renderOptions, isFirstRender) => {
  const { query, widgetParams } = renderOptions;

  if (isFirstRender) {
    widgetParams.inputElement.addEventListener('change', (event) => {
      widgetParams.onSelection(event.target.value);
    });
    radiusSelect.disableRadiusSelect();
  }

  return query ? updateUrlQueryParams(widgetParams.key, query) : false;
};

const radiusSelect = {
  getRadius,
  enableRadiusSelect,
  disableRadiusSelect,
  renderRadiusSelect,
};

export default radiusSelect;
