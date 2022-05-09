const popup = (popupData) => (`
<div class="pop-up">
  <p class="govuk-heading-s marker-title govuk-!-margin-bottom-2">
    <a href="${popupData.heading_url}" class="govuk-link">${popupData.heading_text}</a>
  </p>
  <ul class="govuk-list govuk-body-s">
    <li>${popupData.description ? popupData.description : ''}</li>
    <li>${popupData.address}</li>
  </ul>
  ${Array.isArray(popupData.details) ? popupData.details.map((detail) => `<dl><dt>${detail.label}</dt><dd>${detail.value}</dt></dd></dl>`).join('') : ''}
</div>`);

export default popup;
