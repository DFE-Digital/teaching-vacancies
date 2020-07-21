import {
  onChange,
} from './location';

import { enableRadiusSelect, disableRadiusSelect } from './radius';

jest.mock('../../../lib/api');
jest.mock('./radius');

describe('location search box', () => {
  describe('onChange (input)', () => {
    test('disables the radius input if the input value does not contain a number', () => {
      onChange('london');
      expect(disableRadiusSelect).not.toHaveBeenCalled();
    });

    test('enables the radius input if the input value does contain a number', () => {
      onChange('w1');
      expect(enableRadiusSelect).toHaveBeenCalledTimes(1);
    });
  });
});
