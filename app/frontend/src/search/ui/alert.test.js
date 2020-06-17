import { getJobAlertLink, getJobAlertLinkParam } from './alert';

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
