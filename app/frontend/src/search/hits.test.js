import { formatSnakeCase, formatDate } from './hits'

describe('formatSnakeCase', () => {
    test('should format an array of snake case strings for display', () => {
        expect(formatSnakeCase('secondary_girls_school')).toBe('secondary girls school');
    })
})

describe('formatDate', () => {
    test('should format UNIX timestamp to m, d, y, t string for display', () => {
        expect(formatDate(1587488218)).toBe('April 21, 2020, 5:56 PM');
    })
})