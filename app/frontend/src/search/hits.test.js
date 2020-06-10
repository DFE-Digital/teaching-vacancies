import { createHeadingMarkup, createHeadingHTMLForSearchTerm, getJobAlertLink, getJobAlertLinkParam } from './hits';

describe('createHeadingMarkup', () => {
    test('creates formatted and readable markup for number of results with no search terms', () => {
        expect(createHeadingMarkup({
            count: 582
        })).toBe('There are <span class="govuk-!-font-weight-bold">582</span> jobs listed ');
    });

    test('creates formatted and readable markup to reflect search terms for plural number of results', () => {
        expect(createHeadingMarkup({
            count: 4,
            keyword: 'physics'
        })).toBe('<span class="govuk-!-font-weight-bold">4</span> jobs  match  <span class="govuk-!-font-weight-bold text-wrap-apostrophe">physics</span> ');
        expect(createHeadingMarkup({
            count: 4,
            location: 'W12 8QT'
        })).toBe('<span class="govuk-!-font-weight-bold">4</span> jobs found near <span class="govuk-!-font-weight-bold text-capitalize text-wrap-apostrophe">W12 8QT</span>');
        expect(createHeadingMarkup({
            count: 4,
            keyword: 'physics',
            location: 'W12 8QT'
        })).toBe('<span class="govuk-!-font-weight-bold">4</span> jobs  match  <span class="govuk-!-font-weight-bold text-wrap-apostrophe">physics</span> near <span class="govuk-!-font-weight-bold text-capitalize text-wrap-apostrophe">W12 8QT</span>');
    });

    test('creates formatted and readable markup to reflect search terms for one result', () => {
        expect(createHeadingMarkup({
            count: 1
        })).toBe('There is <span class="govuk-!-font-weight-bold">1</span> job listed ');
        expect(createHeadingMarkup({
            count: 1,
            keyword: 'physics'
        })).toBe('<span class="govuk-!-font-weight-bold">1</span> job  matches  <span class="govuk-!-font-weight-bold text-wrap-apostrophe">physics</span> ');
        expect(createHeadingMarkup({
            count: 1,
            keyword: 'physics',
            location: 'W12 8QT'
        })).toBe('<span class="govuk-!-font-weight-bold">1</span> job  matches  <span class="govuk-!-font-weight-bold text-wrap-apostrophe">physics</span> near <span class="govuk-!-font-weight-bold text-capitalize text-wrap-apostrophe">W12 8QT</span>');
    });
});

describe('createHeadingHTMLForSearchTerm', () => {
    test('returns a string of capitalized words after a prefix', () => {
        expect(createHeadingHTMLForSearchTerm('176 jobs near', 'babylon gardens', true)).toBe('176 jobs near <span class="govuk-!-font-weight-bold text-capitalize text-wrap-apostrophe">babylon gardens</span>');
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
