/**
 * @jest-environment jsdom
 */

import { Application } from '@hotwired/stimulus';

import LocationFinderController, {
  ERROR_MESSAGE, DEFAULT_PLACEHOLDER, LOADING_PLACEHOLDER,
} from './locationFinder';

let application;
let controller;

const initialiseStimulus = () => {
  application = Application.start();
  application.register('location-finder', LocationFinderController);
};

jest.mock('./api');

export const currentPosition = (coords) => ({
  getCurrentPosition: jest.fn().mockImplementationOnce((success) => Promise.resolve(success(coords))),
});

let addLoaderMock;
let removeLoaderMock;

beforeAll(() => {
  document.body.innerHTML = `<div><input type="text" id="location-input" /></div>
  <div data-controller="location-finder" data-location-finder-source-value="getPostcodeFromCoordinates" data-location-finder-input-value="location-input">
  <a data-action="click->location-finder#findLocation" data-location-finder-target="button">find location</a></div>`;

  LocationFinderController.loader.add = jest.fn();
  addLoaderMock = jest.spyOn(LocationFinderController.loader, 'add');

  LocationFinderController.loader.remove = jest.fn();
  removeLoaderMock = jest.spyOn(LocationFinderController.loader, 'remove');

  initialiseStimulus();
});

describe('when coordinates are available from browser geolocation API', () => {
  beforeEach(() => {
    controller = application.getControllerForElementAndIdentifier(document.querySelector('[data-controller="location-finder"]'), 'location-finder');

    global.navigator.geolocation = currentPosition({
      coords: {
        latitude: 51.1,
        longitude: 45.3,
      },
    });
  });

  it('should display result in input element', (done) => {
    controller.buttonTarget.click();
    setTimeout(() => {
      try {
        expect(addLoaderMock).toHaveBeenCalledWith(controller.input.parentElement, LOADING_PLACEHOLDER);
        expect(controller.input.value).toEqual('E2 0BT');
        expect(removeLoaderMock).toHaveBeenCalledWith(controller.input.parentElement, DEFAULT_PLACEHOLDER);
        done();
      } catch (error) {
        done(error);
      }
    });
  });
});

describe('when coordinates are not available from browser geolocation API', () => {
  beforeEach(() => {
    controller = application.getControllerForElementAndIdentifier(document.querySelector('[data-controller="location-finder"]'), 'location-finder');
    global.navigator.geolocation = currentPosition({
      coords: {},
    });
  });

  it('should display error message to user', (done) => {
    controller.buttonTarget.click();

    setTimeout(() => {
      try {
        expect(addLoaderMock).toHaveBeenCalledWith(controller.input.parentElement, LOADING_PLACEHOLDER);
        expect(controller.input.value).toEqual('');
        expect(removeLoaderMock).toHaveBeenCalledWith(controller.input.parentElement, DEFAULT_PLACEHOLDER);
        expect(document.getElementById('location-finder__error').innerHTML).toEqual(ERROR_MESSAGE);
        done();
      } catch (error) {
        done(error);
      }
    });

    controller.input.focus();

    expect(document.getElementById('location-finder__error')).toBe(null);
  });
});
