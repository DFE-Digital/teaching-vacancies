import { onChange as locationChange, getCoords } from './ui/input/location';
import { disableRadiusSelect } from './ui/input/radius';
import { renderAutocomplete } from '../patterns/autocomplete';
import { getLocationSuggestions } from '../lib/api';

const SEARCH_THRESHOLD = 3;

window.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('jobs-search-form-location-field')) {
    if (!getCoords()) {
      disableRadiusSelect();
    }

    renderAutocomplete({
      container: document.getElementsByClassName('location-text')[0],
      input: document.getElementById('jobs-search-form-location-field'),
      threshold: SEARCH_THRESHOLD,
      getOptions: getLocationSuggestions,
      key: 'location',
    });

    document.getElementById('jobs-search-form-location-field').addEventListener('input', (e) => {
      locationChange(e.target.value);
    });
  }

  if (document.getElementById('subscription-form-location-field')) {
    renderAutocomplete({
      container: document.getElementsByClassName('location-text')[0],
      input: document.getElementById('subscription-form-location-field'),
      threshold: SEARCH_THRESHOLD,
      getOptions: getLocationSuggestions,
      key: 'location',
    });
  }
});
