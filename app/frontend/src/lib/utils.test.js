import {
  getUnixTimestampForDayStart, constructNewUrlWithParam, stringMatchesPostcode, convertMilesToMetres, convertEpochToUnixTimestamp, extractQueryParams,
} from './utils';

describe('constructNewUrlWithParams', () => {
  test('activates autocomplete if threshold has been met', () => {
    expect(constructNewUrlWithParam(
      'location',
      's',
      'https://jobs?radius=20&location=&job_title=#job-count',
    )).toBe(
      'https://jobs?radius=20&location=s&job_title=#job-count',
    );

    expect(constructNewUrlWithParam(
      'location',
      'so',
      'https://jobs?radius=20&location=s&job_title=#job-count',
    )).toBe(
      'https://jobs?radius=20&location=so&job_title=#job-count',
    );
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
    validPostcodes.map((postcode) => expect(stringMatchesPostcode(postcode)).toBe(true));
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
    invalidPostcodes.map((postcode) => expect(stringMatchesPostcode(postcode)).toBe(false));
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

describe('extractQueryParams', () => {
  test('extracts specified query parameters as object of key values from a url string', () => {
    const url = '/jobs?utf8=%E2%9C%93&keyword=physics&location=london&jobs_sort=&commit=Search#job-count';
    expect(extractQueryParams(url, ['keyword', 'location'])).toStrictEqual({ keyword: 'physics', location: 'london' });
    expect(extractQueryParams(url, ['keyword', 'place'])).toStrictEqual({ keyword: 'physics' });
  });
});

describe('getUnixTimestampForDayStart', () => {
  test('get the UNIX timestamp of the beggining of a supplied date', () => {
    expect(getUnixTimestampForDayStart(new Date('2020-05-28T18:45:34.181Z'))).toBe(1590624000);
  });
});
