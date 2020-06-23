import axios from 'axios';

export const getGeolocatedCoordinates = (query) => {
  return axios.get(`/api/v1/coordinates/${query}?format=json`).then((response) => {
    return response.data;
  });
};

export const getLocationPolygon = (query) => {
  return axios.get(`/api/v1/location_polygons/${query}?format=json`).then((response) => {
    return response.data;
  });
};
