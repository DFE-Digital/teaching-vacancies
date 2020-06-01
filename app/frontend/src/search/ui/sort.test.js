import { renderSortSelect, constructOptions } from './sort';

describe('renderSortSelect', () => {
    test('should return a function', () => {
        expect(typeof renderSortSelect).toBe('function');
    });
});

describe('constructOptions', () => {
    test('constructs HTML options for select tag with the selected option attribute set', () => {

        const options = [
            {
                value: 'v1',
                label: 'l1'
            },
            {
                value: 'v2',
                label: 'l2'
            }
        ];
        expect(constructOptions(options, 'v2')).toBe(`<option value="v1">l1</option><option value="v2" selected>l2</option>`); // eslint-disable-line
    });
});
