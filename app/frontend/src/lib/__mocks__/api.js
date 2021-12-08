export const getPostcodeFromCoordinates = (latitude, longitude) => {
  if (latitude && longitude) {
    return Promise.resolve('E2 0BT');
  }

  return Promise.reject(new Error());
};

const mapDataMock = [
  [
    {
      type: 'marker',
      data: {
        point: [51, 0.14],
        meta: {
          name: 'Bexleyheath Academy',
        },
      },
    },
    {
      type: 'marker',
      data: {
        point: [51, 0.18],
      },
    },
  ],
  [
    {
      type: 'polygon',
      data: {
        point: [51.5, 0.14],
        coordinates: [],
      },
    },
    {
      type: 'marker',
      data: {
        point: [51.4, 0.18],
      },
    },
  ],
];

export const getMapData = () => Promise.resolve(mapDataMock.reduce((a, b) => a.concat(b), []));

const api = {
  getPostcodeFromCoordinates,
  getMapData,
};

export default api;
