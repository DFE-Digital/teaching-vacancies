import {
  onChange,
  onLoad,
  INPUT_ELEMENT_CLASSNAME,
} from './location';

import { enableRadiusSelect, disableRadiusSelect } from './radius';

jest.mock('../../lib/api');
jest.mock('./radius');

describe('location search box', () => {
  beforeEach(() => {
    jest.resetAllMocks();
  });
  describe('onLoad', () => {
    test('disables the radius input if no point (coordinates) available', () => {
      document.body.innerHTML = `<input class="${INPUT_ELEMENT_CLASSNAME}" />`;
      onLoad(document.getElementsByClassName(INPUT_ELEMENT_CLASSNAME)[0]);
      expect(disableRadiusSelect).toHaveBeenCalledTimes(1);
      expect(enableRadiusSelect).toHaveBeenCalledTimes(0);
    });
  });

  describe('onLoad', () => {
    test('does not disable the radius input if point (coordinates) available', () => {
      document.body.innerHTML = `<input class="${INPUT_ELEMENT_CLASSNAME}" data-coordinates="10,10" />`;
      onLoad(document.getElementsByClassName(INPUT_ELEMENT_CLASSNAME)[0]);
      expect(disableRadiusSelect).toHaveBeenCalledTimes(0);
      expect(enableRadiusSelect).toHaveBeenCalledTimes(0);
    });
  });
  describe('onChange (input)', () => {
    test('disables the radius input if the input value does not contain a number', () => {
      onChange('london');
      expect(disableRadiusSelect).toHaveBeenCalledTimes(1);
    });

    test('enables the radius input if the input value does contain a number', () => {
      onChange('w1');
      expect(enableRadiusSelect).toHaveBeenCalledTimes(1);
    });
  });
});
