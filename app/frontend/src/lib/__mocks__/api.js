export const getPostcodeFromCoordinates = (latitude, longitude) => {
  if (latitude && longitude) {
    return Promise.resolve('E2 0BT');
  }

  return Promise.reject(new Error());
};

const api = {
  getPostcodeFromCoordinates,
};

export default api;
