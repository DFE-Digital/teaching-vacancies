import { getLocationSuggestions } from '../lib/api';
import autocomplete from '../components/autocomplete/autocomplete';

import '../components/form/form';
import '../components/clipboard/clipboard';
import '../components/uploadDocuments/uploadDocuments';
import '../components/locationFinder/locationFinder';
import './jobseekers/map';
import '../components/manageQualifications/manageQualifications';

window.addEventListener('DOMContentLoaded', () => {
  const locationAutocompleteInputs = ['jobseekers-subscription-form-location-field', 'location-field'];
  autocomplete(locationAutocompleteInputs, getLocationSuggestions);
});
