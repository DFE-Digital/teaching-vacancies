import accessibleAutocomplete from 'accessible-autocomplete';
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css';
import './autocomplete.scss';

const SHOW_SUGGESTIONS_THRESHOLD = 3;

const highlightRefinement = (text, refinement) => {
  const index = text.toLowerCase().indexOf(refinement.toLowerCase());

  /* eslint-disable max-len */
  return `${text.substring(0, index)}<span class='accessible-autocomplete__suggestion-highlight'>${text.substring(index, index + refinement.length)}</span>${text.substring(index + refinement.length, text.length)}`;
  /* eslint-enable */
};

const autocomplete = (fieldIds, source) => {
  fieldIds.forEach((elementId) => {
    const formInput = document.getElementById(elementId);

    if (formInput) {
      let currentInputValue = formInput.value;
      formInput.parentNode.removeChild(formInput);

      accessibleAutocomplete({
        element: document.querySelector('#accessible-autocomplete'),
        id: elementId,
        name: formInput.name,
        defaultValue: currentInputValue,
        source: (query, populateResults) => {
          currentInputValue = query;
          return source({ query, populateResults });
        },
        minLength: SHOW_SUGGESTIONS_THRESHOLD,
        templates: {
          suggestion: (value) => highlightRefinement(value, currentInputValue),
        },
        tNoResults: () => 'Loading...',
      });
    }
  });
};

export default autocomplete;
