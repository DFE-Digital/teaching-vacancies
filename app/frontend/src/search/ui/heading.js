export const createHeadingMarkup = (options) => {
  const { count, keyword = '', location = '' } = options;

  const searchTermsHTML = `${getSearchTermsPrefix(location, keyword, count)}${createHeadingHTMLForSearchTerm('', keyword, false)} ${createHeadingHTMLForSearchTerm('near', location, true)}`;
  const countHTML = keyword || location ? `<span class="govuk-!-font-weight-bold">${count}</span>` : `There ${count > 1 ? 'are' : 'is'} <span class="govuk-!-font-weight-bold">${count}</span>`;

  return `${countHTML} ${count > 1 ? 'jobs' : 'job'} ${searchTermsHTML}`;
};

export const getSearchTermsPrefix = (location, keyword, count) => {
  let prefix = 'listed';
  if (keyword.length) {
    prefix = ` ${count > 1 ? 'match' : 'matches'} `;
  } else if (location.length) {
    prefix = 'found';
  }

  return prefix;
};

export const createHeadingHTMLForSearchTerm = (pre, string, capitalize) => (string ? `${pre} <span class="govuk-!-font-weight-bold${capitalize ? ' text-capitalize' : ''} text-wrap-apostrophe">${string}</span>` : '');
