import { renderAutocomplete } from './lib/autocomplete';
import { locations } from './search/data/locations';

$(document).ready(function () {
    if ($('#new_').length) {
        renderAutocomplete({
            widgetParams: {
                container: document.querySelector('#new_'),
                input: document.querySelector('#location'),
                dataset: locations,
                threshold: 3,
                onSelection: () => { }
            }
        })
    }
});
