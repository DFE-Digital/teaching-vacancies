import '../../patterns/currentLocation';
import { onChange as locationChange, getCoords } from './location';
import { disableRadiusSelect } from './radius';
import { renderAutocomplete } from '../../patterns/autocomplete';
import { getLocationSuggestions } from '../../lib/api';
import { hideSortSubmit, sortChange } from './sort';

const SEARCH_THRESHOLD = 3;

window.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('location-field')) {
    if (!getCoords()) {
      disableRadiusSelect();
    }

    renderAutocomplete({
      container: document.getElementsByClassName('location-text')[0],
      input: document.getElementById('location-field'),
      threshold: SEARCH_THRESHOLD,
      getOptions: getLocationSuggestions,
      key: 'location',
    });

    document.getElementById('location-field').addEventListener('input', (e) => {
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

  if (document.getElementById('jobs-sort-field')) {
    hideSortSubmit();

    document.getElementById('jobs-sort-field').addEventListener('input', () => {
      sortChange();
    });
  }
});
