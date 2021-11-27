/**
 * @jest-environment jsdom
 */

import { Application } from '@hotwired/stimulus';

import LocationFinderController, {
  ERROR_MESSAGE, DEFAULT_PLACEHOLDER, LOADING_PLACEHOLDER,
} from './locationFinder';

const initialiseStimulus = () => {
  const application = Application.start();
  application.register('locationFinder', LocationFinderController);
};

jest.mock('../../lib/api');

export const currentPosition = (coords) => ({
  getCurrentPosition: jest.fn().mockImplementationOnce((success) => Promise.resolve(success(coords))),
});

let actionEl;
let inputEl;
let addLoaderMock;
let removeLoaderMock;
let inputContainerEl;

describe('location finder', () => {
  beforeEach(() => {
    initialiseStimulus();

    document.body.innerHTML = `<div class="location-input__container">
    <input type="text" id="location-input" />
    </div>
    <a
    data-target="location-input"
    data-controller="locationFinder"
    data-source="getPostcodeFromCoordinates"
    data-action="click->locationFinder#findLocation"
    class="find-location-button">
    find location
    </a>`;

    LocationFinderController.loader.add = jest.fn();
    addLoaderMock = jest.spyOn(LocationFinderController.loader, 'add');

    LocationFinderController.loader.remove = jest.fn();
    removeLoaderMock = jest.spyOn(LocationFinderController.loader, 'remove');

    [actionEl] = document.getElementsByClassName('find-location-button');
    [inputContainerEl] = document.getElementsByClassName('location-input__container');
    inputEl = document.getElementById('location-input');
  });

  describe('when coordinates are available from browser geolocation api', () => {
    beforeAll(() => {
      global.navigator.geolocation = currentPosition({
        coords: {
          latitude: 51.1,
          longitude: 45.3,
        },
      });
    });

    test('postcode is added to input box', (done) => {
      actionEl.click();

      setTimeout(() => {
        try {
          expect(addLoaderMock).toHaveBeenCalledWith(inputContainerEl, LOADING_PLACEHOLDER);
          expect(inputEl.value).toEqual('E2 0BT');
          expect(removeLoaderMock).toHaveBeenCalledWith(inputContainerEl, DEFAULT_PLACEHOLDER);
          done();
        } catch (error) {
          done(error);
        }
      });
    });
  });

  describe('when coordinates are not available from browser geolocation api', () => {
    beforeAll(() => {
      global.navigator.geolocation = currentPosition({
        coords: {},
      });
    });

    test('error message is displayed to user', (done) => {
      actionEl.click();

      setTimeout(() => {
        try {
          expect(addLoaderMock).toHaveBeenCalledWith(inputContainerEl, LOADING_PLACEHOLDER);
          expect(inputEl.value).toEqual('');
          expect(removeLoaderMock).toHaveBeenCalledWith(inputContainerEl, DEFAULT_PLACEHOLDER);

          expect(document.getElementById('location-finder__error').innerHTML).toEqual(ERROR_MESSAGE);

          done();
        } catch (error) {
          done(error);
        }
      });
    });

    test('when input is focused error message is removed', () => {
      inputEl.focus();
      expect(document.getElementById('location-finder__error')).toBe(null);
    });
  });
});
