import axios from 'axios'

export const getCoordinates = query => {
    return axios.get(`/api/v1/coordinates/${query}?format=json`).then(response => {
        return response.data;
    });
};
