import axios from 'axios';
import Rollbar from './logging';

export const getGeolocatedCoordinates = (query) => axios.get(`/api/v1/coordinates/${query}?format=json`).then((response) => response.data);

export const getPostcodeFromCoordinates = (latitude, longitude) => axios.get('https://api.postcodes.io/postcodes', {
  params: { latitude, longitude },
}).then((response) => response.data);

export const getPlaceOptionsFromSearchQuery = (query) => axios.get(`/api/v1/location_suggestion/${query}.json`)
  .then((response) => response.data)
  .then((data) => data.suggestions)
  .catch((error) => {
    Rollbar.log(`${error} Search query: ${query}`);
  });

const api = {
  getGeolocatedCoordinates,
  getPostcodeFromCoordinates,
  getPlaceOptionsFromSearchQuery
};

export default api;
