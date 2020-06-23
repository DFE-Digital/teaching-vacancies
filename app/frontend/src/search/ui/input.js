import { enableSubmitButton } from './form';
import { updateUrlQueryParams } from '../../lib/utils';

export const renderSearchBox = (renderOptions, isFirstRender) => {
  const { widgetParams } = renderOptions;

  if (isFirstRender) {
    widgetParams.inputElement.addEventListener('input', () => {
      enableSubmitButton(widgetParams.container);
    });

    widgetParams.inputElement.addEventListener('change', () => {
      enableSubmitButton(widgetParams.container);
    });

    widgetParams.container.addEventListener('submit', (e) => {
      e.preventDefault();
      updateUrlQueryParams(widgetParams.key, widgetParams.inputElement.value, window.location.href);
      widgetParams.onSubmit(widgetParams.inputElement.value);
    });
  }
};
