/* global fetch */

export const getCoordinates = query => {
    return fetch(`https://localhost:3000/api/v1/coordinates/${query}?format=json`).then(data => {
        return data.json();
    });
};
