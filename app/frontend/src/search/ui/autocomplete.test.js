import { isActive, getOptions } from './autocomplete';

describe('isActive', () => {
    test('should activate autocomplete if threshold has been met', () => {
        expect(isActive(3, 'so')).toBe(false);
        expect(isActive(3, 'sou')).toBe(true);
        expect(isActive(3, 'sout')).toBe(true);
    });
});

const options = [
    'apple',
    'banana',
    'apple apple',
    'banana apple',
    'applebanana',
    'cherry'
];

describe('getOptions', () => {
    test('should return an array of matches that contain the supplied query', () => {
        expect(getOptions(options, 'appl')).toEqual(['apple', 'apple apple', 'banana apple', 'applebanana']);
        expect(getOptions(options, 'a')).toEqual(['apple', 'banana', 'apple apple', 'banana apple', 'applebanana']);
        expect(getOptions(options, '')).toEqual(options);
    });
});
