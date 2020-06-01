/* global window */
import { extractQueryParams } from '../lib/utils';
import '../polyfill/remove.polyfill';

export const renderContent = (renderOptions) => {
  const { results, widgetParams } = renderOptions;

  if (results) {
    widgetParams.container.innerHTML = addHeadingMarkup(results.nbHits);
    if (results.query.length >= widgetParams.threshold) {
      addJobAlertMarkup(widgetParams.alert);
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

export const addHeadingMarkup = (numberHits) => {
  const keyword = document.getElementById('keyword').value;
  const location = document.getElementById('location').value;
  const prefix = keyword || location ? ' match ' : ' listed';
  const postfix = `${prefix}${createCapitalisedStringWithPrefix('', keyword)} ${createCapitalisedStringWithPrefix('near', location)}`;
  const hits = keyword || location ? numberHits : `There are ${numberHits}`;

  return `${hits} jobs ${postfix}`;
};

export const createCapitalisedStringWithPrefix = (pre, string) => {
  return string ? `${pre} ${string.replace(/\b\w/g, l => l.toUpperCase() )}` : '';
};

export const hideServerMarkup = () => {
  document.querySelector('ul.vacancies').style.display = 'none';

  if (document.querySelector('ul.pagination-server')) {
    document.querySelector('ul.pagination-server').style.display = 'none';
  }
};

export const snakeCaseToHumanReadable = value => value.toLowerCase().replace(/_/g, ' ');

export const transform = items => items.map(item => ({
  ...item,
  working_patterns: Array.isArray(item.working_patterns) ? item.working_patterns.map(snakeCaseToHumanReadable).join(', ') : item.working_patterns,
}));

export const templates = {
  item: `
<article class="vacancy" role="article">
  <h2 class="govuk-heading-m mb0" role="heading" aria-level="2">
    <a href="/jobs/{{ permalink }}" class="govuk-link view-vacancy-link">
    {{ job_title }}
    </a>
    </h2>
  <p>{{ school.name }}, {{ school.town }}, {{ school.region }}.</p>
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
{{ working_patterns }}
</dd>
<dt>Closing date</dt>
<dd class="double">
{{ expires_at }}
</dd>
</dl>
</article>
`,
empty: '<h4 class="govuk-heading-m">Try another search</h4><ul class="govuk-list govuk-list--bullet"><li>with different keywords</li><li>and/or a wider radius</li></ul>',};

export const customTemplates = {
  alert: `
  <div class="govuk-inset-text" id="job-alert-cta">
<span class="job-seeker-alert-icon">
<svg height="16" viewBox="0 0 20 16" width="20" xmlns="http://www.w3.org/2000/svg">
<path d="M18 0H2C.9 0 0 .9 0 2v12a2 2 0 0 0 2 2h16c1.1 0 2-.9 2-2V2a2 2 0 0 0-2-2zm-.4 4.25l-7.07 4.42c-.32.2-.74.2-1.06 0L2.4 4.25a.85.85 0 1 1 .9-1.44L10 7l6.7-4.19a.85.85 0 1 1 .9 1.44zm0 0" fill="#0b0c0c"></path>
<image src="/packs/media/images/job-seeker-alert-icon-4ad035e860f39781ba7b99c29ccb47ff.png"></image>
</svg>
</span>
<a class="govuk-link" id="job-alert-link" href="/">Subscribe to a job alert.</a>
We’ll email you whenever a job matching this search is published.
</div>
`};
