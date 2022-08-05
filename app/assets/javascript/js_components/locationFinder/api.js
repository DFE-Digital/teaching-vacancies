import axios from 'axios';

export const getPostcodeFromCoordinates = (latitude, longitude) => axios.get('https://api.postcodes.io/postcodes', {
  params: { latitude, longitude },
}).then((response) => response.data.result[0].postcode)
  .catch(() => {

  });

const api = {
  getPostcodeFromCoordinates,
};

export default api;
