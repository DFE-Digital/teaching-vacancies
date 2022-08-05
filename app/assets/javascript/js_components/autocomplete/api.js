import axios from 'axios';

export const getLocationSuggestions = ({ query, populateResults }) => axios.get(`/api/v1/location_suggestion/${query}?format=json`)
  .then((response) => response.data)
  .then((data) => data.suggestions)
  .then(populateResults)
  .catch(() => {

  });

const api = {
  getLocationSuggestions,
};

export default api;
