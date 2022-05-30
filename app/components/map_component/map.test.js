/**
 * @jest-environment jsdom
 */

import { Application } from '@hotwired/stimulus';

import MapController from './map_component';

let application;

const initialiseStimulus = () => {
  application = Application.start();
  application.register('map', MapController);
};

const point = JSON.stringify({ type: 'Point', coordinates: [-0.1583477, 51.46761] });

const getMarkerHTML = (count, type) => {
  let markerHTML = '';
  for (let step = 0; step < count; step += 1) {
    markerHTML += `<div data-map-target='marker' data-marker-type=${type} data-point=${point}></div>`;
  }
  return markerHTML;
};

let spies;

beforeAll(() => {
  document.body.innerHTML = `<div class='map-component' id='map-component' data-controller='map' data-radius='12' data-point=${point}>
  <div id='markers'></div>
    <div class="map-component__container">
      <div class="map-component__sidebar" data-map-target="sidebar"></div>
      <div class='map-component__map' id='map'></div>
    </div>
  </div>`;

  jest.mock('./map_component', () => jest.fn().mockImplementation(() => ({
    addLayer: jest.fn(),
    addMarker: jest.fn(),
  })));

  spies = {
    addMarker: jest.spyOn(MapController.prototype, 'addMarker'),
    addLayer: jest.spyOn(MapController.prototype, 'addLayer'),
  };
});

describe('when map is initialised with no layers', () => {
  beforeAll(() => {
    jest.resetAllMocks();
    initialiseStimulus();
  });

  test('a map is not rendered', () => {
    expect(document.querySelector('.map-component__map').children.length).toEqual(0);
  });
});

describe('when map is initialised with layers', () => {
  beforeAll(() => {
    document.getElementById('markers').insertAdjacentHTML('afterbegin', getMarkerHTML(1, 'vacancy'));
    document.getElementById('markers').insertAdjacentHTML('afterbegin', getMarkerHTML(1, 'organisation'));
    document.getElementById('map-component').setAttribute('data-polygons', JSON.stringify({ type: 'MultiPolygon', coordinates: [[[[0, 0], [0, 2], [2, 2]], [[0, 0], [0, 1], [1, 1]]]] }));
    jest.resetAllMocks();
    initialiseStimulus();
  });

  const markerOptions = {
    point: { type: 'Point', coordinates: [-0.1583477, 51.46761] },
    variant: 'location',
  };

  test('location marker is added to map', () => {
    expect(spies.addMarker).toHaveBeenNthCalledWith(1, { point: { type: 'Point', coordinates: [-0.1583477, 51.46761] }, variant: 'location', title: 'Search location' });
  });

  markerOptions.addToLayer = expect.any(Object);

  test('organisation marker is added to map', () => {
    markerOptions.variant = 'pin';
    markerOptions.title = 'Vacancy location';
    markerOptions.details = {
      target: {
        data: expect.any(Function),
        eventHandlers: {
          open: expect.any(Function),
          close: expect.any(Function),
          focus: expect.any(Function),
          interaction: expect.any(Function),
        },
        ui: 'default',
      },
      open: false,
    };

    expect(spies.addMarker).toHaveBeenNthCalledWith(2, markerOptions);
  });

  test('vacancy marker is added to map', () => {
    markerOptions.variant = 'pin';
    markerOptions.title = 'Vacancy';
    markerOptions.details = {
      target: {
        data: expect.any(Function),
        eventHandlers: {
          open: expect.any(Function),
          close: expect.any(Function),
          focus: expect.any(Function),
          interaction: expect.any(Function),
        },
        ui: 'custom',
      },
      open: false,
    };
    expect(spies.addMarker).toHaveBeenNthCalledWith(3, markerOptions);
  });

  test('polygons and radius circles are added to map', () => {
    expect(spies.addLayer).toHaveBeenCalledTimes(3);
  });
});
