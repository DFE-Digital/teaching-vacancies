import '../polyfill/classlist.polyfill';
import '../polyfill/after.polyfill';
import '../polyfill/remove.polyfill';
import '../loader';
import axios from 'axios';

const input = document.querySelector('.js-location-finder__input');
const container = document.querySelector('.js-location-finder');
const link = document.getElementById('current-location');

const loader = new GOVUK.Loader();

export const startLoading = () => {
    input.disabled = true;
    container.classList.add('js-location-finder--loading');
    loader.init({
        container: 'js-location-finder__input-container',
        size: 32,
        label: true,
        labelText: 'Finding location...'
    });
}

export const stopLoading = () => {
    loader.stop();
    container.classList.remove('js-location-finder--loading');
    input.removeAttribute('disabled');
}

export const showLocationLink = () => {
    container.classList.add('js-geolocation-supported');
}

export const showErrorMessage = () => {
    const errorMessage = document.createElement('div');
    errorMessage.classList.add('govuk-error-message');
    errorMessage.classList.add('govuk-!-margin-top-2');
    errorMessage.innerHTML = 'Unable to find your location';
    link.after(errorMessage);
}

export const removeErrorMessage = () => {
    if (document.querySelector('.js-location-finder__link .govuk-error-message')) {
        document.querySelector('.js-location-finder__link .govuk-error-message').remove();
    }
}

export const postcodeFromPosition = (position) => {
    return axios.get('https://api.postcodes.io/postcodes', {
        params: {
            lat: position.coords.latitude,
            lon: position.coords.longitude
        }
    }).then(response => {
        if (response.result) {
            document.getElementById('location').value = response.result[0].postcode;
            document.getElementById('radius').removeAttribute('disabled');
        } else {
            showErrorMessage();
        }

        stopLoading();
    }).catch(() => {
        showErrorMessage();
        stopLoading();
    });
}

if (navigator.geolocation) {
    showLocationLink();
}

link.addEventListener('click', (event) => {
    event.stopPropagation();

    startLoading();

    navigator.geolocation.getCurrentPosition(postcodeFromPosition, stopLoading);
});

input.addEventListener('focus', () => {
    removeErrorMessage();
});
