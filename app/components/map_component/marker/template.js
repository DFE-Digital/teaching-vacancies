const popup = (data) => (`
<div class="popup">
  <h4 class="popup-title govuk-!-margin-bottom-2">
    ${link(data.heading_url, data.heading_text, data.anonymised_id)}
  </h4>
  <ul class="govuk-list govuk-body-s">
    <li>${data.description ? data.description : ''}</li>
    <li>${data.address}</li>
  </ul>
</div>`);

const sidebar = (data) => (`
<h2 class="popup-title govuk-!-margin-bottom-1 govuk-!-font-size-16">
${link(data.heading_url, data.heading_text, data.anonymised_id)}
</h2>
<p class="govuk-body-s govuk-!-margin-bottom-2">${data.name}, ${data.address}</p>
${Array.isArray(data.details) ? data.details.map((detail) => `<dl><dt class="govuk-!-font-weight-bold">${detail.label}</dt><dd>${detail.value}</dt></dd></dl>`).join('') : ''}
`);

const link = (url, text, trackingId) => (`
<a class="popup-link govuk-link govuk-!-font-weight-bold"
${trackingId ? `data-controller="tracked-link"
data-action="click->tracked-link#track auxclick->tracked-link#track contextmenu->tracked-link#track"
data-tracked-link-target="link" data-link-type="school_website_from_map"
data-link-subject="${trackingId}"` : ''}
href="${url}" class="govuk-link">
${text}</a>
`);

export default { popup, sidebar };
