const protocol = process.env.DOMAIN.includes('localhost') ? 'http' : 'https';
const apiBase = `${protocol}://${process.env.DOMAIN}`;

const TvJobs = {
  init: () => {
    const containers = document.querySelectorAll('[data-tv-jobs]');
    const customStylingEnabled = containers[0].getAttribute('data-tv-us-style');

    TvJobs.loadStyles(customStylingEnabled);

    containers.forEach(async (container) => {
      const schoolSlug = container.getAttribute('data-tv-school');
      const jobTemplateFn = container.getAttribute('data-tv-job-template-fn');

      if (!schoolSlug) {
        container.innerHTML = '<div class="tv-jobs__error">Missing school slug.</div>';
        return;
      }

      container.innerHTML = '<div class="tv-jobs__loading">Loading jobs...</div>';

      try {
        const jobs = await TvJobs.fetchJobs(schoolSlug);
        TvJobs.renderJobs(container, jobs.data, jobTemplateFn);
      } catch (error) {
        container.innerHTML = `<div class="tv-jobs__error">Failed to load jobs: ${error.message}</div>`;
      }
    });
  },

  loadStyles: (customStylingEnabled) => {
    if (!customStylingEnabled) {
      const css = `
      .tv-jobs { max-width: 800px; border: 1px solid black; }
      .tv-jobs .tv-jobs__loading { padding: 20px; text-align: center; color: #666; }
      .tv-jobs .tv-jobs__error { padding: 20px; background: #fee; border-left: 3px solid #c00; color: #c00; }
      .tv-jobs .tv-jobs__job { border: 1px solid #ddd; margin-bottom: 16px; padding: 16px; border-radius: 4px; }
      .tv-jobs .tv-jobs__job:hover { box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
      .tv-jobs .tv-jobs__title { font-size: 18px; font-weight: 600; margin: 0 0 8px; color: #222; }
`;
      const style = document.createElement('style');
      style.textContent = css;
      document.head.appendChild(style);
    }
  },

  fetchJobs: async (schoolSlug) => {
    const response = await fetch(`${apiBase}/api/v1/organisations/${schoolSlug}.json`);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  },

  getJobTemplate: (Name) => {
    if (!Name) {
      return TvJobs.defaultJobTemplate;
    }

    const template = window[Name];

    if (template === undefined) {
      return TvJobs.defaultJobTemplate;
    }

    return (job) => {
      try {
        return template(job);
      } catch (error) {
        return `Template error: ${error.message}`;
      }
    };
  },

  defaultJobTemplate: (job) => {
    const escapeHtml = (text) => {
      const div = document.createElement('div');
      div.textContent = text;
      return div.innerHTML;
    };

    return `
      <div class="tv-jobs__job">
        <h3 class="tv-jobs__title">
          <span class="govuk-!-margin-right-2">
            <a hrefy="${job.url}">${escapeHtml(job.title)}</a>
          </span>
        </h3>
        <dl class="tv-jobs__summary-list">
          <div class="job-embed__summary-list__row">
            <dt>Published date</dt><dd>${escapeHtml(job.datePosted)}</dd>
            <dt>Closure date</dt><dd>${escapeHtml(job.validThrough)}</dd>
            <dt>Location</dt><dd></dd>
          </div>
        </dl>
      </div>
    `;
  },

  renderJobs: (container, jobs, jobTemplateFn) => {
    if (jobs.length === 0) {
      container.innerHTML = '<div>No jobs available.</div>';
      return;
    }

    const templateFn = TvJobs.getJobTemplate(jobTemplateFn);
    const html = jobs.map((job) => templateFn(job)).join('');

    container.innerHTML = html;
  },
};

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => { TvJobs.init(); });
} else {
  TvJobs.init();
}

export default TvJobs;
