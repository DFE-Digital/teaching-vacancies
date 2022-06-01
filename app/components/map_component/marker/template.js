const popup = (data) => {
  const html = `<div class="popup">
                <h4 class="govuk-!-margin-bottom-2">
                  <a class="tracked govuk-link govuk-body-m govuk-!-font-weight-bold"
                  href="${data.heading_url}">${data.heading_text}</a>
                </h4>
                <ul class="govuk-list govuk-body-s">
                  <li>${data.description ? data.description : ''}</li>
                  <li>${data.address}</li>
                </ul>
              </div>`;
  return template(html, data.anonymised_id, data.trackingType);
};

const sidebar = (data) => {
  const html = `<div class="sidebar">
                <div id="sidebar-content" role="dialog" aria-live="polite">
                <h2 class="popup-title govuk-!-margin-bottom-1 govuk-!-font-size-16">
                <a class="tracked govuk-link govuk-!-font-weight-bold"
                href="${data.heading_url}">${data.heading_text}</a>
                </h2>
                <p class="govuk-body-s govuk-!-margin-bottom-2">${data.name}, ${data.address}</p>
                </div>
                ${Array.isArray(data.details) ? data.details.map((detail) => `<dl><dt class="govuk-!-font-weight-bold">${detail.label}</dt><dd>${detail.value}</dt></dd></dl>`).join('') : ''}
                </div>`;

  return template(html, data.anonymised_id, data.trackingType);
};

const template = (html, trackingId, trackingType) => {
  const el = document.createElement('template');
  el.innerHTML = html;

  if (trackingId) {
    const tracking = trackingAttributes(trackingId, trackingType);
    Object.keys(tracking).forEach((a) => { el.content.querySelector('.tracked').dataset[a] = tracking[a]; });
  }

  return el.content.firstChild;
};

const trackingAttributes = (id, type) => ({
  controller: 'tracked-link',
  action: 'click->tracked-link#track auxclick->tracked-link#track contextmenu->tracked-link#track',
  trackedLinkTarget: 'link',
  linkType: type,
  linkSubject: id,
});

export default { popup, sidebar, trackingAttributes };
