import { getFilters } from './query';

describe('getFilters', () => {
    test('returns a string', () => {
        expect(typeof getFilters()).toBe('string');
    });
});
