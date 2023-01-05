import axios from 'axios';

import logger from '../../lib/logging';

export const getLocationSuggestions = ({ query, populateResults }) => axios.get(`/api/v1/location_suggestion/${query}?format=json`)
  .then((response) => response.data)
  .then((data) => data.suggestions)
  .then(populateResults)
  .catch((error) => {
    logger.warn(error.message);
  });

const api = {
  getLocationSuggestions,
};

export default api;
