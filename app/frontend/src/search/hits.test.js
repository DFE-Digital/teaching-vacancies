import { snakeCaseToHumanReadable, createCapitalisedStringWithPrefix, transform, getJobAlertLink } from './hits';

describe('snakeCaseToHumanReadable', () => {
    test('formats an array of snake case strings for display', () => {
        expect(snakeCaseToHumanReadable('Secondary_girls_school')).toBe('secondary girls school');
    });
});

describe('createCapitalisedStringWithPrefix', () => {
    test('returns a string of capitalized words after a prefix', () => {
        expect(createCapitalisedStringWithPrefix('176 jobs near', 'babylon gardens')).toBe('176 jobs near Babylon Gardens');
    });
});

describe('transform', () => {
    test('converts each vacancy in array to renderable values', () => {

        const items = [
            {
                working_patterns: ['pattern 1', 'pattern 2'],
                somethingElse: 'abc'
            },
            {
                working_patterns: 'pattern 3',
                somethingElse: 'xyz'
            }
        ]
        expect(transform(items)).toStrictEqual([{'somethingElse': 'abc', 'working_patterns': 'pattern 1, pattern 2'}, {'somethingElse': 'xyz', 'working_patterns': 'pattern 3'}]);
    });
});

describe('getJobAlertLink', () => {
    test('returns a string of capitalized words after a prefix', () => {
        expect(getJobAlertLink('/jobs?utf8=✓&keyword=&location=south%20gloucestershire')).toBe('/subscriptions/new?%26search_criteria%5Blocation%5D%3Dsouth%20gloucestershire');
        expect(getJobAlertLink('/jobs?utf8=✓&keyword=maths&location=south%20gloucestershire')).toBe('/subscriptions/new?%26search_criteria%5Bkeyword%5D%3Dmaths%26search_criteria%5Blocation%5D%3Dsouth%20gloucestershire')
    });
});