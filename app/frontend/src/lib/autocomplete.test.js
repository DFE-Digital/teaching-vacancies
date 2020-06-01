import { isActive, getOptions } from './autocomplete';

describe('isActive', () => {
    test('should activate autocomplete if threshold has been met', () => {
        expect(isActive(3, 'sou')).toBe(true);
        expect(isActive(3, 'sout')).toBe(true);
    });

    test('should not activate autocomplete if threshold hasnt been met', () => {
        expect(isActive(3, 'so')).toBe(false);
        expect(isActive(3, '')).toBe(false);
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
    test('should return an array of matches from the options array that contain the supplied string', () => {
        expect(getOptions(options, 'appl')).toEqual(['apple', 'apple apple', 'banana apple', 'applebanana']);
        expect(getOptions(options, 'a')).toEqual(['apple', 'banana', 'apple apple', 'banana apple', 'applebanana']);
    });

    test('should return an array of matches from the options irrespective of letter case', () => {
        expect(getOptions(options, 'Appl')).toEqual(['apple', 'apple apple', 'banana apple', 'applebanana']);
        expect(getOptions(options, 'ApPL')).toEqual(['apple', 'apple apple', 'banana apple', 'applebanana']);
    });
});
