const popup = (popupData) => (`
<div class="popup">
  <h4 class="popup-title govuk-!-margin-bottom-2">
    ${link(popupData.heading_url, popupData.heading_text, popupData.anonymised_id)}
  </h4>
  <ul class="govuk-list govuk-body-s">
    <li>${popupData.description ? popupData.description : ''}</li>
    <li>${popupData.address}</li>
  </ul>
  ${Array.isArray(popupData.details) ? popupData.details.map((detail) => `<dl><dt>${detail.label}</dt><dd>${detail.value}</dt></dd></dl>`).join('') : ''}
</div>`);

const link = (url, text, trackingId) => (`
<a class="popup-link"
${trackingId ? `data-controller="tracked-link"
data-action="click->tracked-link#track auxclick->tracked-link#track contextmenu->tracked-link#track"
data-tracked-link-target="link" data-link-type="school_website_from_map"
data-link-subject="${trackingId}"` : ''}
href="${url}" class="govuk-link">
${text}</a>
`);

export default popup;
