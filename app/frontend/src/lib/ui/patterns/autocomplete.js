import view from './autocomplete.view';
import { getLocationSuggestionsFromSearchQuery } from '../../api';

export const renderAutocomplete = (widgetParams) => {
  view.create(widgetParams.container, widgetParams.input, widgetParams.onSelect);

  widgetParams.input.addEventListener('input', async () => {
    if (widgetParams.input.value.length >= 3) {
      getLocationSuggestionsFromSearchQuery(widgetParams.input.value).then((suggestions) => {
        updateLocationListBox(widgetParams, suggestions);
      });
    } else {
      updateLocationListBox(widgetParams, []);
    }
  });
};

export const updateLocationListBox = (widgetParams, options) => {
  isActive(widgetParams.threshold, widgetParams.input.value)
    ? view.show(options, widgetParams.container, widgetParams.input)
    : view.hide(widgetParams.container, widgetParams.input);
};

export const isActive = (threshold, currentInput) => (currentInput ? currentInput.length >= threshold : false);

const autocomplete = {
  view,
  renderAutocomplete,
};

export default autocomplete;
