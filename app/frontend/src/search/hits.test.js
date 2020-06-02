import { snakeCaseToHumanReadable, createCapitalisedStringWithPrefix, transform, getJobAlertLink, getJobAlertLinkParam } from './hits';

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
                somethingElse: 'abc',
                school: {
                    region : 'south east',
                    county : 'kent'
                }
            },
            {
                working_patterns: 'pattern 3',
                somethingElse: 'xyz',
                school: {
                    county : 'surrey'
                }
            }
        ];
        expect(transform(items)).toStrictEqual([
            {
                'somethingElse': 'abc',
                'working_patterns': 'pattern 1, pattern 2',
                'school': {
                    'county': 'kent',
                    'region': 'south east'
                },
                'school_region': 'south east'
            },
            {
                'somethingElse': 'xyz',
                'working_patterns': 'pattern 3',
                'school': {
                    'county': 'surrey'
                },
                'school_region': 'surrey'
            }
        ]);
    });
});

describe('getJobAlertLink', () => {
    test('returns a string of capitalized words after a prefix', () => {
        expect(getJobAlertLink('/jobs?utf8=✓&keyword=&location=south%20gloucestershire')).toBe('/subscriptions/new?search_criteria%5Blocation%5D=south+gloucestershire&search_criteria%5Blocation_category%5D=south+gloucestershire&');
        expect(getJobAlertLink('/jobs?utf8=✓&keyword=maths&location=south%20gloucestershire&radius=10')).toBe('/subscriptions/new?search_criteria%5Bkeyword%5D=maths&search_criteria%5Blocation%5D=south+gloucestershire&search_criteria%5Blocation_category%5D=south+gloucestershire&search_criteria%5Bradius%5D=10&');
    });
});

describe('getJobAlertLinkParam', () => {
    test('converts key,value to valid url parameter string', () => {
        expect(getJobAlertLinkParam('location', 'south east')).toBe('search_criteria%5Blocation%5D=south+east&');
    });
});
