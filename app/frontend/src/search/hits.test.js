import { snakeCaseToHumanReadable } from './hits';

describe('snakeCaseToHumanReadable', () => {
    test('formats an array of snake case strings for display', () => {
        expect(snakeCaseToHumanReadable('Secondary_girls_school')).toBe('secondary girls school');
    });
});
