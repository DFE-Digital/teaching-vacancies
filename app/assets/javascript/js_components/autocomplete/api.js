import axios from 'axios';

import logger from '../../lib/logging';

const getSuggestions = (url, populateResults) => axios.get(url)
  .then((response) => response.data)
  .then((data) => data.suggestions)
  .then(populateResults)
  .catch((error) => {
    if (error.response && (error.response.status !== 200 || error.response.status !== 204)) {
      logger.warn(error.message);
    } else {
      logger.log(error.message);
    }
  });

export const getLocationSuggestions = ({ query, populateResults }) => getSuggestions(`/api/v1/location_suggestion/${query}?format=json`, populateResults);
export const getOrganisations = ({ query, populateResults }) => getSuggestions(`/api/v1/organisations?query=${query}&format=json`, populateResults);

const api = {
  getLocationSuggestions,
  getOrganisations,
};

export default api;
