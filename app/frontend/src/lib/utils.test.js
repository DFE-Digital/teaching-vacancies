/**
 * @jest-environment jsdom
 */

import {
  getNewState, getUnixTimestampForDayStart, stringMatchesPostcode, convertMilesToMetres, convertEpochToUnixTimestamp, stringContainsNumber, railsCsrfToken,
} from './utils';

describe('getNewState', () => {
  test('returns state object with new properties', () => {
    expect(getNewState(
      { prop: 'has this' },
      { newProp: 'add' },
    )).toStrictEqual({
      prop: 'has this',
      newProp: 'add',
    });

    expect(getNewState(
      { prop: 'has this' },
      { prop: 'overwrite' },
    )).toStrictEqual({
      prop: 'overwrite',
    });
  });

  test('does not mutate state', () => {
    const state = { prop: 'has this' };
    getNewState(state, { newProp: 'add' });
    expect(state).toStrictEqual({
      prop: 'has this',
    });
  });
});

describe('stringMatchesPostcode', () => {
  const validPostcodes = [
    'CT9 5ST',
    'ct9 5ST',
    'ct9 5St',
    'CT95ST',
    'SE18 2BT',
    'SE182BT',
    'B2 5ST',
    'B25ST',
    'SW1A 1AA',
    'SW1A 1aa',
    'Sw1A 1aA',
  ];

  test('matches a correct postcode', () => {
    validPostcodes.forEach((postcode) => expect(stringMatchesPostcode(postcode)).toBe(true));
  });

  const invalidPostcodes = [
    'CT 5ST',
    'CT5ST',
    'SEF8 2BT',
    'SEF82BT',
    'B2 %ST',
    'B2%ST',
  ];

  test('matches a correct postcode', () => {
    invalidPostcodes.forEach((postcode) => expect(stringMatchesPostcode(postcode)).toBe(false));
  });
});

describe('stringContainsNumber', () => {
  test('is true when supplied string contains a number', () => {
    expect(stringContainsNumber('alex8')).toBe(true);
  });

  test('is falsy when supplied string doesnt contain a number', () => {
    expect(stringContainsNumber('alex')).toBe(false);
  });
});

describe('convertMilesToMetres', () => {
  test('converts an integer of number of miles to the equivalent in metres', () => {
    expect(convertMilesToMetres(1)).toBe(1610);
  });

  test('converts a string of number of miles to the equivalent in metres', () => {
    expect(convertMilesToMetres('1')).toBe(1610);
  });
});

describe('convertEpochToUnixTimestamp', () => {
  test('converts an epoch timestamp to unix format', () => {
    expect(convertEpochToUnixTimestamp(1589351356458)).toBe(1589351356);
    expect(convertEpochToUnixTimestamp(1589351356658)).toBe(1589351357);
  });
});

describe('getUnixTimestampForDayStart', () => {
  test('get the UNIX timestamp of the beggining of a supplied date', () => {
    expect(getUnixTimestampForDayStart(new Date('2020-05-28T18:45:34.181Z'))).toBe(1590624000);
  });
});

describe('railsCsrfToken', () => {
  describe('when the token is present in the document', () => {
    beforeEach(() => {
      document.head.innerHTML = '<meta name="csrf-token" content="aloha">';
    });

    test('extracts the Rails CSRF token from the HTML', () => {
      expect(railsCsrfToken()).toBe('aloha');
    });
  });

  describe('when the token is missing from the document', () => {
    beforeEach(() => {
      document.head.innerHTML = '<html><blink>Nothing to see here</blink></html>';
    });

    test('returns undefined', () => {
      expect(railsCsrfToken()).toBeUndefined();
    });
  });
});
