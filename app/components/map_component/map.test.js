/**
 * @jest-environment jsdom
 */

import { Application } from '@hotwired/stimulus';

import MapController from './map';

const initialiseStimulus = () => {
  const application = Application.start();
  application.register('map', MapController);
};

jest.mock('../../frontend/src/lib/api');
const mockCreate = jest.fn();
const mockCluster = jest.fn();
const mockCreatePolygon = jest.fn();
const mockAddMarkerToCluster = jest.fn();
const mockSetMapBounds = jest.fn();
const mockcreatePopupMarker = jest.fn();
let spies;

const getMarkerHTML = (count) => {
  let markerHTML = '';
  for (let step = 0; step < count; step += 1) {
    markerHTML += '<div data-map-target="marker" data-lat="51" data-lon="0.14"><div class="pop-up"></div></div>';
  }
  return markerHTML;
};

beforeEach(() => {
  document.body.innerHTML = `<div class="map-component" id="map-component" data-controller="map" data-zoom="12">
  <div data-map-target="markersTextList" id="markers"></div>
  <div class="map-component__map" id="map"></div>
  </div>`;
  jest.resetAllMocks();
});

beforeAll(() => {
  MapController.prototype.addMapLayer = jest.fn();

  jest.mock('./map', () => jest.fn().mockImplementation(() => ({
    create: mockCreate,
    createCluster: mockCluster,
    createPopupMarker: mockcreatePopupMarker,
    createPolygon: mockCreatePolygon,
    addMarkerToCluster: mockAddMarkerToCluster,
    setMapBounds: mockSetMapBounds,
  })));

  spies = {
    create: jest.spyOn(MapController.prototype, 'create'),
    createPopupMarker: jest.spyOn(MapController, 'createPopupMarker'),
    createPolygon: jest.spyOn(MapController, 'createPolygon'),
    cluster: jest.spyOn(MapController.prototype, 'createCluster'),
    addMarkerToCluster: jest.spyOn(MapController.prototype, 'addMarkerToCluster'),
    setMapBounds: jest.spyOn(MapController.prototype, 'setMapBounds'),
    addMapLayer: jest.spyOn(MapController.prototype, 'addMapLayer'),
  };
});

describe('when map is initialised with one item', () => {
  beforeEach(() => {
    document.getElementById('markers').insertAdjacentHTML('afterbegin', getMarkerHTML(1));
    initialiseStimulus();
  });

  test('a map object is created with one marker', () => {
    expect(spies.create).toHaveBeenCalledTimes(1);
    expect(spies.create).toHaveBeenCalledWith({ lat: '51', lon: '0.14' }, '12');
    expect(spies.cluster).not.toHaveBeenCalled();
    expect(spies.createPopupMarker).toHaveBeenCalledTimes(1);
    expect(spies.addMarkerToCluster).not.toHaveBeenCalled();
    expect(spies.addMapLayer).not.toHaveBeenCalled();
    expect(spies.setMapBounds).not.toHaveBeenCalled();
  });
});

describe('when map is initialised with a polygon', () => {
  beforeEach(() => {
    document.getElementById('markers').insertAdjacentHTML('afterbegin', getMarkerHTML(1));
    document.getElementById('map-component').setAttribute('data-polygon', '[[[0, 0],[0, 1],[1, 1],[1, 0]]]');
    initialiseStimulus();
  });

  test('a map object is created with one marker', () => {
    expect(spies.create).toHaveBeenCalledTimes(1);
    expect(spies.create).toHaveBeenCalledWith({ lat: '51', lon: '0.14' }, '12');
    expect(spies.cluster).not.toHaveBeenCalled();
    expect(spies.createPopupMarker).toHaveBeenCalledTimes(1);
    expect(spies.createPolygon).toHaveBeenCalledTimes(1);
    expect(spies.addMarkerToCluster).not.toHaveBeenCalled();
    expect(spies.addMapLayer).toHaveBeenCalledTimes(1);
    expect(spies.setMapBounds).not.toHaveBeenCalled();
  });
});

describe('when map is initialised with more than one marker', () => {
  beforeEach(() => {
    document.getElementById('markers').insertAdjacentHTML('afterbegin', getMarkerHTML(3));
    initialiseStimulus();
  });

  test('a map object is created with markers added to cluster', () => {
    expect(spies.create).toHaveBeenCalledTimes(1);
    expect(spies.create).toHaveBeenCalledWith({ lat: '51', lon: '0.14' }, '12');
    expect(spies.cluster).toHaveBeenCalledTimes(1);
    expect(spies.createPopupMarker).toHaveBeenCalledTimes(3);
    expect(spies.addMarkerToCluster).toHaveBeenCalledTimes(3);
    expect(spies.addMapLayer).toHaveBeenCalledTimes(1);
    expect(spies.setMapBounds).toHaveBeenCalledTimes(1);
  });
});
