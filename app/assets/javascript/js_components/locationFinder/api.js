import axios from 'axios';
import logger from '../../lib/logging';

export const getPostcodeFromCoordinates = (latitude, longitude) => axios.get('https://api.postcodes.io/postcodes', {
  params: { latitude, longitude },
}).then((response) => response.data.result[0].postcode)
  .catch((error) => {
    logger.log(`${error} Postcodes API`);
  });

const api = {
  getPostcodeFromCoordinates,
};

export default api;
