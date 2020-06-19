import { enableSubmitButton } from './form';

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
      widgetParams.onSubmit(widgetParams.inputElement.value);
    });
  }
};
