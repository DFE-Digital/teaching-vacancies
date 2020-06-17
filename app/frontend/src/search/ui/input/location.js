import { setGeocodeAttributes, removeGeocodeAttributes } from '../form';
import { enableRadiusSelect, disableRadiusSelect } from './radius';
import { getGeolocatedCoordinates } from '../../../lib/api';

export const shouldNotGeocode = (query, locations) => query.length && locations.indexOf(query.toLowerCase()) > -1; // eslint-disable-line

export const geocodeSuccess = (coords, client) => {
  if (coords.success) {
    enableRadiusSelect();
    setGeocodeAttributes(coords);
    client.refresh();
  }
};

export const onSubmit = (query, locations, client) => {
  if (shouldNotGeocode(query, locations)) {
    disableRadiusSelect();
    removeGeocodeAttributes();
    client.refresh();
  } else {
    getGeolocatedCoordinates(query).then((coords) => {
      geocodeSuccess(coords, client);
    });
  }
};

export const getCoords = () => document.querySelector('#location').dataset.coordinates;
