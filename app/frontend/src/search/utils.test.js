import { constructNewUrlWithParam, stringMatchesPostcode } from './utils';

describe('constructNewUrlWithParams', () => {
    test('should activate autocomplete if threshold has been met', () => {
        expect(constructNewUrlWithParam(
            'location',
            's',
            'https://jobs?radius=20&location=&job_title=#vacancy-results'
        )).toBe(
            'https://jobs?radius=20&location=s&job_title=#vacancy-results'
        );

        expect(constructNewUrlWithParam(
            'location',
            'so',
            'https://jobs?radius=20&location=s&job_title=#vacancy-results'
        )).toBe(
            'https://jobs?radius=20&location=so&job_title=#vacancy-results'
        );
    });
});

describe('stringMatchesPostcode', () => {
    test('should test that string matching correct postcode is true', () => {
        expect(stringMatchesPostcode('CT9 5ST')).toBe(true);
        expect(stringMatchesPostcode('CT95ST')).toBe(true);
        expect(stringMatchesPostcode('SE18 2BT')).toBe(true);
        expect(stringMatchesPostcode('SE182BT')).toBe(true);
        expect(stringMatchesPostcode('B2 5ST')).toBe(true);
        expect(stringMatchesPostcode('B25ST')).toBe(true);
    });

    test('should test that string matching incorrect postcode is false', () => {
        expect(stringMatchesPostcode('CT 5ST')).toBe(false);
        expect(stringMatchesPostcode('CT5ST')).toBe(false);
        expect(stringMatchesPostcode('SEF8 2BT')).toBe(false);
        expect(stringMatchesPostcode('SEF82BT')).toBe(false);
        expect(stringMatchesPostcode('B2 %ST')).toBe(false);
        expect(stringMatchesPostcode('B2%ST')).toBe(false);
    });
});
