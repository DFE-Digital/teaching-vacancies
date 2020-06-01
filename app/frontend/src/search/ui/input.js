import { getQuery } from '../query';
import { enableSubmitButton } from './form';

export const renderSearchBox = (renderOptions, isFirstRender) => {
    const { refine, widgetParams } = renderOptions;

    if (isFirstRender) {

        if (getQuery().length) {
            refine(getQuery());
        }

        if (widgetParams.onChange) {
            widgetParams.onChange(widgetParams.inputElement.value);
        }

        widgetParams.inputElement.addEventListener('input', () => {
            enableSubmitButton(widgetParams.container);

            if (widgetParams.onChange) {
                widgetParams.onChange(widgetParams.inputElement.value);
            }
        });

        widgetParams.inputElement.addEventListener('change', () => {
            enableSubmitButton(widgetParams.container);

            if (widgetParams.onChange) {
                widgetParams.onChange(widgetParams.inputElement.value);
            }
        });

        widgetParams.container.addEventListener('submit', (e) => {
            e.preventDefault();
            refine();
        });
    }
};
