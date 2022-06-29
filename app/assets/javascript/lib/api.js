import axios from 'axios';
import logger from './logging';

export const getPostcodeFromCoordinates = (latitude, longitude) => axios.get('https://api.postcodes.io/postcodes', {
  params: { latitude, longitude },
}).then((response) => response.data.result[0].postcode)
  .catch((error) => {
    logger.log(`${error} Postcodes API`);
  });

export const getLocationSuggestions = ({ query, populateResults }) => axios.get(`/api/v1/location_suggestion/${query}?format=json`)
  .then((response) => response.data)
  .then((data) => data.suggestions)
  .then(populateResults)
  .catch((error) => {
    logger.log(`${error} Search query: ${query}`);
  });

const api = {
  getPostcodeFromCoordinates,
  getLocationSuggestions,
};

export default api;
