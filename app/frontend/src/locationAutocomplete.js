import { renderAutocomplete } from './lib/ui/patterns/autocomplete';
import { locations } from './search/data/locations';

window.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('new_')) {
    renderAutocomplete({
      container: document.getElementById('new_'),
      input: document.getElementById('location'),
      dataset: locations,
      threshold: 3,
      onSelection: () => { },
    });
  }
});
