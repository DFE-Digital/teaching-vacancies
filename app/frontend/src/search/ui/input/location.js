import {
  setGeocodeAttributes, removeGeocodeAttributes, setPolygonAttributes, removePolygonAttributes,
} from '../form';
import { enableRadiusSelect, disableRadiusSelect } from './radius';
import { getGeolocatedCoordinates, getLocationPolygon } from '../../../lib/api';

export const onSubmit = (query, locations, client) => {
  client.helper.setPage(0); // if the search input changes, the page should be reset to 0
  removePolygonAttributes();
  if (shouldNotGeocode(query, locations)) {
    disableRadiusSelect();
    removeGeocodeAttributes();
    getLocationPolygon(query).then((polygon) => {
      if (polygon.success) {
        polygonSuccess(polygon.polygon, client);
      } else {
        client.refresh();
      }
    });
  } else {
    getGeolocatedCoordinates(query).then((coords) => {
      geocodeSuccess(coords, client);
    });
  }
};

export const shouldNotGeocode = (query, locations) => query.length && locations.indexOf(query.toLowerCase()) > -1; // eslint-disable-line

export const geocodeSuccess = (coords, client) => {
  if (coords.success) {
    enableRadiusSelect();
    setGeocodeAttributes(coords);
    client.refresh();
  }
};

export const polygonSuccess = (polygon, client) => {
  setPolygonAttributes(polygon);
  client.refresh();
};

export const getCoords = () => document.querySelector('#location').dataset.coordinates;

export const getPolygon = () => document.querySelector('#location').dataset.polygon;
