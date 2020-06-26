import axios from 'axios';

export const getGeolocatedCoordinates = (query) => axios.get(`/api/v1/coordinates/${query}?format=json`).then((response) => response.data);

export const getPostcodeFromCoordinates = (latitude, longitude) => axios.get('https://api.postcodes.io/postcodes', {
  params: { latitude, longitude },
}).then((response) => response.data);
