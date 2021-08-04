import accessibleAutocomplete from 'accessible-autocomplete';
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css';
import { getLocationSuggestions } from '../../lib/api';
import '../../components/locationFinder/locationFinder';

import './manageQualifications';
import './map';

const AUTOCOMPLETE_THRESHOLD = 3;

window.addEventListener('DOMContentLoaded', () => {
  const locationAutocompleteInputs = ['jobseekers-subscription-form-location-field', 'location-field'];
  const hiddenFormInput = document.getElementById('location-id');

  locationAutocompleteInputs.forEach((elementId) => {
    const formInput = document.getElementById(elementId);

    if (formInput) {
      formInput.parentNode.removeChild(formInput);

      accessibleAutocomplete({
        element: document.querySelector('#location-autocomplete'),
        id: elementId,
        name: 'location',
        source: (query, populateResults) => getLocationSuggestions({ query, populateResults }),
        onConfirm: (value) => { hiddenFormInput.value = value; },
        minLength: AUTOCOMPLETE_THRESHOLD,
        tNoResults: () => 'Loading...',
      });
    }
  });
});
