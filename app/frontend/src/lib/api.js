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

export const getMapData = (items) => Promise.all(items.map((item) => api[`${item.type.toLowerCase()}Request`](item.params)));

export const locationRequest = ({ location, radius }) => axios.get(`/api/v1/map/location/${location}/${radius}?format=json`)
  .then((response) => response.data)
  .catch((error) => {
    logger.log(error);
  });

export const vacancyRequest = ({ type, id }) => axios.get(`/api/v1/map/vacancy/${type}/${id}?format=json`)
  .then((response) => response.data)
  .catch((error) => {
    logger.log(error);
  });

const api = {
  getPostcodeFromCoordinates,
  getLocationSuggestions,
  getMapData,
  locationRequest,
  vacancyRequest,
};

export default api;
