import { snakeCaseToHumanReadable, timestampToHumanReadable } from './hits';

describe('snakeCaseToHumanReadable', () => {
    test('should format an array of snake case strings for display', () => {
        expect(snakeCaseToHumanReadable('Secondary_girls_school')).toBe('secondary girls school');
    });
});

describe('timestampToHumanReadable', () => {
    test('should format UNIX timestamp to m, d, y, t string for display', () => {
        expect(timestampToHumanReadable(1587488218)).toBe('April 21, 2020, 5:56 PM');
    });
});
