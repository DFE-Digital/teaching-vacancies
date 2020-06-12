import { setGeocodeAttributes, removeGeocodeAttributes } from '../form';
import { enableRadiusSelect, disableRadiusSelect } from './radius';
import { stringMatchesPostcode } from '../../../lib/utils';
import { getGeolocatedCoordinates } from '../../../lib/api';

export const onSubmit = (query, locations, client) => {
    if (shouldGeocode(query, locations)) {
        getGeolocatedCoordinates(query).then(coords => {
            geocodeSuccess(coords, client);
        });
    } else {
        disableRadiusSelect();
        removeGeocodeAttributes();
        client.refresh();
    }
};

export const shouldGeocode = (query, locations) => stringMatchesPostcode(query) || (query.length && locations.indexOf(query.toLowerCase()) === -1);

export const geocodeSuccess = (coords, client) => {
    if (coords.success) {
        enableRadiusSelect();
        setGeocodeAttributes(coords);
        client.refresh();
    }
};

export const getCoords = () => document.querySelector('#location').dataset.coordinates;
