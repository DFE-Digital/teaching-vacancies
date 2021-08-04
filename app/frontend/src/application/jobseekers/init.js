import accessibleAutocomplete from 'accessible-autocomplete';
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css';
import { getLocationSuggestions } from '../../lib/api';
import '../../components/locationFinder/locationFinder';

import './manageQualifications';
import './map';

const AUTOCOMPLETE_THRESHOLD = 3;

window.addEventListener('DOMContentLoaded', () => {
  const hiddenFormInput = document.getElementById('location-id');
  const fbFormInput = document.getElementById('location-field');
  fbFormInput.style.display = 'none';

  accessibleAutocomplete({
    element: document.querySelector('#location-autocomplete'),
    id: 'location-field',
    name: 'location',
    source: (query, populateResults) => getLocationSuggestions({ query, populateResults }),
    onConfirm: (value) => { hiddenFormInput.value = value.id; },
    minLength: AUTOCOMPLETE_THRESHOLD,
    tNoResults: () => 'Loading...',
  });
});
