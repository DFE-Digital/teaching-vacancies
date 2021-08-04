import accessibleAutocomplete from 'accessible-autocomplete';
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css';
import './autocomplete.scss';

const AUTOCOMPLETE_THRESHOLD = 3;

const highlightRefinement = (text, refinement) => {
  const index = text.toLowerCase().indexOf(refinement.toLowerCase());

  if (index >= 0) {
    /* eslint-disable */
    return `${text.substring(0, index)}<span class='accessible-autocomplete__suggestion-highlight'>${text.substring(index, index + refinement.length)}</span>${text.substring(index + refinement.length, text.length)}`;
    /* eslint-enable */
  }

  return text;
};

const init = (fieldIds, source) => {
  fieldIds.forEach((elementId) => {
    const formInput = document.getElementById(elementId);

    if (formInput) {
      let currentInputValue = formInput.value;
      formInput.parentNode.removeChild(formInput);

      accessibleAutocomplete({
        element: document.querySelector('#accessible-autocomplete'),
        id: elementId,
        name: 'location',
        defaultValue: currentInputValue,
        source: (query, populateResults) => {
          currentInputValue = query;
          return source({ query, populateResults });
        },
        minLength: AUTOCOMPLETE_THRESHOLD,
        templates: {
          suggestion: (value) => highlightRefinement(value, currentInputValue),
        },
        tNoResults: () => 'Loading...',
      });
    }
  });
};

export default init;
