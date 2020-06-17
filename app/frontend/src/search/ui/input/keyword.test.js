import { onSubmit } from './keyword';

describe('keyword search box', () => {

    const client = {};
    let performSearch = null;

    beforeEach(() => {
        client.refresh = jest.fn();
        performSearch = jest.spyOn(client, 'refresh');
    });

    describe('onSubmit', () => {
        test('performs search when onSubmit handler called', () => {
            onSubmit(client);
            expect(performSearch).toHaveBeenCalledTimes(1);
        });
    });
});
