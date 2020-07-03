import { onSubmit, getKeyword } from './keyword';

describe('keyword search box', () => {
  const client = {};
  let performSearch = null; let setPage = null;

  beforeEach(() => {
    client.helper = jest.fn();
    client.helper.setPage = jest.fn();
    setPage = jest.spyOn(client.helper, 'setPage');

    client.refresh = jest.fn();
    performSearch = jest.spyOn(client, 'refresh');
  });

  describe('onSubmit', () => {
    test('performs search when onSubmit handler called', () => {
      onSubmit(client);
      expect(setPage).toHaveBeenNthCalledWith(1, 0);
      expect(performSearch).toHaveBeenCalledTimes(1);
    });
  });

  describe('getKeyword', () => {
    test('to return a string from input box', () => {
      document.body.innerHTML = '<input id="keyword" />';
      expect(typeof getKeyword()).toBe('string');
    });
  });
});
