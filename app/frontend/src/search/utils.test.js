import { constructNewUrlWithParam } from './utils';

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