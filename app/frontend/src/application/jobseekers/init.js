
import { getLocationSuggestions } from '../../lib/api';
import '../../components/locationFinder/locationFinder';
import autocomplete from '../../components/autocomplete/autocomplete';
import './manageQualifications';
import './map';

window.addEventListener('DOMContentLoaded', () => {
  const locationAutocompleteInputs = ['jobseekers-subscription-form-location-field', 'location-field'];
  autocomplete(locationAutocompleteInputs, getLocationSuggestions);
});
