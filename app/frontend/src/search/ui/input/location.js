import { setGeocodeAttributes, removeGeocodeAttributes } from '../form';
import { enableRadiusSelect, disableRadiusSelect } from './radius';
import { getGeolocatedCoordinates } from '../../../lib/api';

export const onSubmit = (query, locations, client) => {
  client.helper.setPage(0); // if the search input changes, the page should be reset to 0
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

export const shouldNotGeocode = (query, locations) => query.length && locations.indexOf(query.toLowerCase()) > -1; // eslint-disable-line

export const geocodeSuccess = (coords, client) => {
  if (coords.success) {
    enableRadiusSelect();
    setGeocodeAttributes(coords);
    client.refresh();
  }
};

export const getCoords = () => {
  if (document.querySelector('#location').dataset.coordinates) {
    return document.querySelector('#location').dataset.coordinates.split(' ').join(',');
  }
  return false;
};
