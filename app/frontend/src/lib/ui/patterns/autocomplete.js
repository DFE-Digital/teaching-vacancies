import view from './autocomplete.view';

export const renderAutocomplete = (widgetParams) => {
  view.create(widgetParams.container, widgetParams.input, widgetParams.onSelect);

  widgetParams.input.addEventListener('input', async () => {
    let options;

    if (widgetParams.input.value.length >= 3) {
      options = await getOptions(widgetParams.input.value);
    } else {
      options = [];
    }

    isActive(widgetParams.threshold, widgetParams.input.value)
      ? view.show(options, widgetParams.container, widgetParams.input)
      : view.hide(widgetParams.container, widgetParams.input);
  });
};

export const isActive = (threshold, currentInput) => (currentInput ? currentInput.length >= threshold : false);

export const getOptions = async (query) => {
  let options = [];
  await fetch(`https://localhost:3000/api/v1/location_suggestion/${query}.json`)
    .then((data) => data.json())
    .then((data) => {
      options = data.suggestions;
    });

  return options;
};

const autocomplete = {
  view,
  renderAutocomplete,
};

export default autocomplete;
