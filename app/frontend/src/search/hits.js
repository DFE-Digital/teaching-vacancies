/* global window */
import { extractQueryParams } from '../lib/utils';
import '../polyfill/remove.polyfill';

export const renderContent = (renderOptions) => {
  const { results, widgetParams } = renderOptions;

  if (results) {
    widgetParams.container.innerHTML = createHeadingMarkup({
      count: results.nbHits,
      keyword: document.getElementById('keyword').value,
      location: document.getElementById('location').value
    });

    if (results.query.length >= widgetParams.threshold) {
      addJobAlertMarkup(widgetParams.container);
      document.querySelector('#job-alert-link').href = getJobAlertLink(window.location.href);
    } else {
      removeJobAlertMarkup();
    }
    hideServerMarkup();
  }
};

export const addJobAlertMarkup = container => {
  !document.getElementById('job-alert-cta') ? container.insertAdjacentHTML('beforeend', customTemplates.alert) : false; 
};

export const removeJobAlertMarkup = () => {
  const el = document.getElementById('job-alert-cta');
  return el && el.remove(); 
};

const JOB_ALERT_URL = '/subscriptions/new';

export const getJobAlertLink = url => {
  const paramsObj = extractQueryParams(url, ['keyword', 'location', 'radius']);
  let queryString = '';

  Object.keys(paramsObj).map(key => {
    queryString += getJobAlertLinkParam(key, paramsObj[key]);

    if (key === 'location') {
      queryString += getJobAlertLinkParam('location_category', paramsObj[key]);
    }
  });

  return `${JOB_ALERT_URL}?${queryString}`;
};

export const getJobAlertLinkParam = (key, value) => {
  return encodeURIComponent(`search_criteria[${key}]`) + `=${value.replace(' ', '+')}&`;
};

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

export const createHeadingHTMLForSearchTerm = (pre, string, capitalize) => {
  return string ? `${pre} <span class="govuk-!-font-weight-bold${capitalize ? ' text-capitalize' : ''} text-wrap-apostrophe">${string}</span>` : '';
};

export const hideServerMarkup = () => {
  document.querySelector('ul.vacancies').style.display = 'none';

  if (document.querySelector('ul.pagination-server')) {
    document.querySelector('ul.pagination-server').style.display = 'none';
  }
};

export const templates = {
  item: `
<article class="vacancy" role="article">
  <h2 class="govuk-heading-m mb0" role="heading" aria-level="2">
    <a href="/jobs/{{ permalink }}" class="govuk-link view-vacancy-link">
    {{ job_title }}
    </a>
    </h2>
  <p>{{ location }}</p>
  <dl>
<dt>Salary</dt>
<dd class="double">
{{ salary }}
</dd>
<dt>School type</dt>
<dd class="double">
{{ school.school_type }}
</dd>
<dt>Working pattern</dt>
<dd class="double">
{{ working_patterns_for_display }}
</dd>
<dt>Closing date</dt>
<dd class="double">
{{ expires_at }}
</dd>
</dl>
</article>
`,
empty: '<h4 class="govuk-heading-m">Try another search</h4><ul class="govuk-list govuk-list--bullet"><li>with different keywords</li><li>and/or a wider radius</li></ul>'};

export const customTemplates = {
  alert: `
  <div id="job-alert-cta" class="govuk-heading-s govuk-!-font-weight-regular govuk-!-margin-0">
<span class="job-seeker-alert-icon">
<svg aria-hidden="true" focusable="false" data-prefix="far" data-icon="bell" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" width="20" height="16"><path fill="#1d70b8" d="M439.39 362.29c-19.32-20.76-55.47-51.99-55.47-154.29 0-77.7-54.48-139.9-127.94-155.16V32c0-17.67-14.32-32-31.98-32s-31.98 14.33-31.98 32v20.84C118.56 68.1 64.08 130.3 64.08 208c0 102.3-36.15 133.53-55.47 154.29-6 6.45-8.66 14.16-8.61 21.71.11 16.4 12.98 32 32.1 32h383.8c19.12 0 32-15.6 32.1-32 .05-7.55-2.61-15.27-8.61-21.71zM67.53 368c21.22-27.97 44.42-74.33 44.53-159.42 0-.2-.06-.38-.06-.58 0-61.86 50.14-112 112-112s112 50.14 112 112c0 .2-.06.38-.06.58.11 85.1 23.31 131.46 44.53 159.42H67.53zM224 512c35.32 0 63.97-28.65 63.97-64H160.03c0 35.35 28.65 64 63.97 64z" class=""/></svg>
</span>
<a class="govuk-link" id="job-alert-link" href="/">Receive a job alert</a>
whenever a job matching this search is published
</div>
`};
