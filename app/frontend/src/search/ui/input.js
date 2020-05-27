import { getQuery } from '../query';
import { enableSubmitButton } from './form';

export const renderSearchBox = (renderOptions, isFirstRender) => {
    const { refine, widgetParams } = renderOptions;

    if (isFirstRender) {

        document.querySelector('#location-radius-select').style.display = 'none';

        if (getQuery().length) {
            refine(getQuery());
        }

        widgetParams.inputElement.addEventListener('input', () => {
            enableSubmitButton(widgetParams.container);

            if (widgetParams.onChange) {
                widgetParams.onChange(document.querySelector('#location').value);
            }
        });

        widgetParams.inputElement.addEventListener('change', () => {
            enableSubmitButton(widgetParams.container);

            if (widgetParams.onChange) {
                widgetParams.onChange(document.querySelector('#location').value);
            }
        });

        widgetParams.container.addEventListener('submit', (e) => {
            e.preventDefault();
            refine();
        });
    }
};