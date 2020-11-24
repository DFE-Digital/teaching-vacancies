import '../../components/locationFinder/locationFinder';
import { renderAutocomplete } from '../../components/autocomplete/autocomplete';
import { getLocationSuggestions } from '../../lib/api';

import './sort';
import './location';
import './map';

const AUTOCOMPLETE_THRESHOLD = 3;

window.addEventListener('DOMContentLoaded', () => {
  Array.from(document.querySelectorAll('.js-location-finder__input')).forEach((fieldEl) => {
    renderAutocomplete({
      container: fieldEl.parentNode,
      input: fieldEl,
      threshold: AUTOCOMPLETE_THRESHOLD,
      getOptions: getLocationSuggestions,
      key: 'location',
    });
  });
});
