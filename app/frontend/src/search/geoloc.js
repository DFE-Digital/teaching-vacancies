/* global fetch */

export const getCoordinates = query => {
    return fetch(`https://localhost:3000/api/v1/coordinates/${query}`).then(data => {
        return data.json();
    });
};