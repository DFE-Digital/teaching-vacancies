/* global fetch */

export const getCoordinates = query => {
    return fetch(`/api/v1/coordinates/${query}?format=json`).then(data => {
        return data.json();
    });
};
