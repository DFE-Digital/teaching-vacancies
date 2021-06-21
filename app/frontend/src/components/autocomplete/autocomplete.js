import 'es6-promise/auto';
import view from './autocomplete.view';

export const renderAutocomplete = (widgetParams) => {
  view.create(widgetParams.container, widgetParams.input, widgetParams.key);

  widgetParams.input.addEventListener('input', () => {
    if (isActive(widgetParams.threshold, widgetParams.input.value.length)) {
      autocomplete.showOptions(widgetParams.getOptions, widgetParams.container, widgetParams.input, widgetParams.key);
    } else {
      autocomplete.clearOptions(widgetParams.container, widgetParams.input);
    }
  });
};

export const removeUnwantedCharacters = (searchTerm) => searchTerm.replace('.', ' ');

export const showOptions = (getOptions, container, input, key) => {
  const searchTerm = removeUnwantedCharacters(input.value);
  return getOptions(searchTerm).then((options) => view.show(options, container, input, key));
};

export const clearOptions = (container, input) => {
  view.hide(container, input);
};

export const isActive = (threshold, inputLength) => inputLength >= threshold;

const autocomplete = {
  view,
  renderAutocomplete,
  removeUnwantedCharacters,
  showOptions,
  clearOptions,
};

export default autocomplete;
