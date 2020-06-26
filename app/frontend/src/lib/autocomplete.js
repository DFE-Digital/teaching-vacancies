import { create, hide, show } from './autocomplete.view';

export const renderAutocomplete = (widgetParams) => {
  create(widgetParams.container, widgetParams.input, widgetParams.onSelection);

  widgetParams.input.addEventListener('input', () => {
    const options = getOptions(widgetParams.dataset, widgetParams.input.value);

    isActive(widgetParams.threshold, widgetParams.input.value)
      ? show(options, widgetParams.container, widgetParams.input)
      : hide(widgetParams.container, widgetParams.input);
  });
};

export const isActive = (threshold, currentInput) => (currentInput ? currentInput.length >= threshold : false);

export const getOptions = (dataset, query) => dataset.filter((option) => option.toLowerCase().indexOf(query.toLowerCase()) >= 0);
