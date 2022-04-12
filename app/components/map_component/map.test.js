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

let createSpy;
let markerSpy;
let mapBoundsSpy;

describe('map', () => {
  beforeAll(() => {
    initialiseStimulus();

    document.body.innerHTML = `<div class="map-component" data-controller="map" data-zoom="12">
    <ol data-map-target="markersTextList">
      <li data-map-target="marker" data-lat="51" data-lon="0.14">
        <div class="pop-up" hidden>
          <a href="https://school.example.com">Test School</a>
        </div>
      </li>
      <li data-map-target="marker" data-lat="52" data-lon="0.15">
        <div class="pop-up" hidden>
          <a href="https://school2.example.com">Test School 2</a>
        </div>
      </li>
      <li data-map-target="marker" data-lat="53" data-lon="0.16">
        <div class="pop-up" hidden>
          <a href="https://school3.example.com">Test School 3</a>
        </div>
      </li>
    </ol>
    <div class="map-component__map" id="map" role="presentation"></div>
    </div>`;

    MapController.prototype.create = jest.fn();
    createSpy = jest.spyOn(MapController.prototype, 'create');

    MapController.prototype.addMarker = jest.fn();
    markerSpy = jest.spyOn(MapController.prototype, 'addMarker');

    MapController.prototype.setMapBounds = jest.fn();
    mapBoundsSpy = jest.spyOn(MapController.prototype, 'setMapBounds');
  });

  describe('when map is initialised with several items', () => {
    test('a map object is created once', () => {
      expect(createSpy).toHaveBeenCalledTimes(1);
      expect(createSpy).toHaveBeenCalledWith({ lat: '51', lon: '0.14' }, '12');
      expect(mapBoundsSpy).toHaveBeenCalledTimes(1);
    });

    test('correct number of items are added to map', () => {
      expect(markerSpy).toHaveBeenCalledTimes(3);
    });
  });
});
