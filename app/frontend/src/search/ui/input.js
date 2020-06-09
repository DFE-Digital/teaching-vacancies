import { getQuery } from '../query';
import { enableSubmitButton } from './form';

export const renderSearchBox = (renderOptions, isFirstRender) => {
    const { refine, widgetParams } = renderOptions;

    if (isFirstRender) {

        if (getQuery().length) {
            refine(getQuery());
        }

        if (widgetParams.onChange) {
            widgetParams.onChange(widgetParams.inputElement.value).then(() => refine());
        }

        widgetParams.inputElement.addEventListener('input', () => {
            if (widgetParams.onChange) {
                widgetParams.onChange(widgetParams.inputElement.value).then(() => enableSubmitButton(widgetParams.container));
            }
        });

        widgetParams.inputElement.addEventListener('change', () => {
            if (widgetParams.onChange) {
                widgetParams.onChange(widgetParams.inputElement.value).then(() => enableSubmitButton(widgetParams.container));
            }
        });

        widgetParams.container.addEventListener('submit', (e) => {
            e.preventDefault();
            widgetParams.onSubmit();
        });
    }
};
