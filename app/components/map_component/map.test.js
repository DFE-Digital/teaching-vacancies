/**
 * @jest-environment jsdom
 */

import { Application } from '@stimulus/core';

import MapController from './map';

const initialiseStimulus = () => {
  const application = Application.start();
  application.register('map', MapController);
};

jest.mock('../../frontend/src/lib/api');

let createSpy;
let markerSpy;
let polygonSpy;

describe('map', () => {
  beforeAll(() => {
    initialiseStimulus();

    document.body.innerHTML = `<div class="map-component" data-controller="map" data-config={} data-zoom="12">
    <div class=".map-component__map" id="map" role="presentation" data-map-target="map"></div></div>`;

    MapController.prototype.create = jest.fn();
    createSpy = jest.spyOn(MapController.prototype, 'create');

    MapController.prototype.polygon = jest.fn();
    polygonSpy = jest.spyOn(MapController.prototype, 'polygon');

    MapController.prototype.marker = jest.fn();
    markerSpy = jest.spyOn(MapController.prototype, 'marker');
  });

  describe('when map is initialised with several items', () => {
    test('a map object is created once', () => {
      expect(createSpy).toHaveBeenCalledTimes(1);
      expect(createSpy).toHaveBeenCalledWith([51, 0.14], '12');
    });

    test('correct number of items are added to map', () => {
      expect(markerSpy).toHaveBeenCalledTimes(3);
      expect(polygonSpy).toHaveBeenCalledTimes(1);
      expect(polygonSpy).toHaveBeenCalledWith({ coordinates: [], point: [51.5, 0.14] });
    });
  });
});
