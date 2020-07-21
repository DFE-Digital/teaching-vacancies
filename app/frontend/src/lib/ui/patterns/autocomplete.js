import view from './autocomplete.view';

export const renderAutocomplete = (widgetParams) => {
  view.create(widgetParams.container, widgetParams.input, widgetParams.onSelect);

  widgetParams.input.addEventListener('input', () => {
    const options = getOptions(widgetParams.dataset, widgetParams.input.value);

    isActive(widgetParams.threshold, widgetParams.input.value)
      ? view.show(options, widgetParams.container, widgetParams.input)
      : view.hide(widgetParams.container, widgetParams.input);
  });
};

export const isActive = (threshold, currentInput) => (currentInput ? currentInput.length >= threshold : false);

export const getOptions = (dataset, query) => dataset.filter((option) => option.toLowerCase().indexOf(query.toLowerCase()) >= 0);

const autocomplete = {
  view,
  renderAutocomplete
}

export default autocomplete;
