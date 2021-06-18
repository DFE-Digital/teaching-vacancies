import axios from 'axios';
import logger from './logging';

export const getPostcodeFromCoordinates = (latitude, longitude) => axios.get('https://api.postcodes.io/postcodes', {
  params: { latitude, longitude },
}).then((response) => response.data)
  .catch((error) => {
    logger.log(`${error} Postcodes API`);
  });

export const getLocationSuggestions = (query) => axios.get(`/api/v1/location_suggestion/${query}?format=json`)
  .then((response) => response.data)
  .then((data) => data.suggestions)
  .catch((error) => {
    logger.log(`${error} Search query: ${query}`);
  });

const api = {
  getPostcodeFromCoordinates,
  getLocationSuggestions,
};

export default api;
