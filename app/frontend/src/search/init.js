import { onChange as locationChange, getCoords } from './ui/input/location';
import { disableRadiusSelect } from './ui/input/radius';
import { renderAutocomplete } from '../lib/ui/patterns/autocomplete';

const SEARCH_THRESHOLD = 2;

window.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('location')) {
    if (!getCoords()) {
      disableRadiusSelect();
    }

    renderAutocomplete({
      container: document.getElementById('location-search'),
      input: document.getElementById('location'),
      threshold: SEARCH_THRESHOLD,
    });

    document.getElementById('location').addEventListener('input', (e) => {
      locationChange(e.target.value);
    });
  }
});
