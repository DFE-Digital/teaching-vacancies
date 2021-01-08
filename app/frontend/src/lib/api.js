import axios from 'axios';
import Rollbar from './logging';

export const getGeolocatedCoordinates = (query) => axios.get(`/api/v1/coordinates/${query}?format=json`)
  .then((response) => response.data)
  .catch((error) => {
    Rollbar.log(`${error} Geolocation: ${query}`);
  });

export const getPostcodeFromCoordinates = (latitude, longitude) => axios.get('https://api.postcodes.io/postcodes', {
  params: { latitude, longitude },
}).then((response) => response.data)
  .catch((error) => {
    Rollbar.log(`${error} Postcodes API`);
  });

export const getLocationSuggestions = (query) => axios.get(`/api/v1/location_suggestion/${query}?format=json`)
  .then((response) => response.data)
  .then((data) => data.suggestions)
  .catch((error) => {
    Rollbar.log(`${error} Search query: ${query}`);
  });

const api = {
  getGeolocatedCoordinates,
  getPostcodeFromCoordinates,
  getLocationSuggestions,
};

export default api;
