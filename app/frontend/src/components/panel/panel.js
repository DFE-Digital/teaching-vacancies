import 'classlist-polyfill';
import { storageAvailable } from '../../lib/utils';
import './panel.scss';

const LOCALSTORAGE_COMPONENT_KEY = 'panel';
const ERROR_LOGGING_MESSAGE = '[Module: dashboard panel]: local storage not available';
export const HIDDEN_CLASS = 'panel--hidden';

export const togglePanel = (options) => {
  if (storageAvailable('localStorage', ERROR_LOGGING_MESSAGE) && !localStorage.getItem(LOCALSTORAGE_COMPONENT_KEY)) {
    localStorage.setItem(LOCALSTORAGE_COMPONENT_KEY, '{}');
    localStorage.setItem(
      LOCALSTORAGE_COMPONENT_KEY,
      JSON.stringify({ [options.componentKey]: options.defaultState }),
    );
  }

  if (options.toggleButton) {
    panel.isInitialStateOpen(options.componentKey) ? panel.openPanel(options) : panel.closePanel(options);

    toggleButtonText(options);

    options.toggleButton.addEventListener('click', () => {
      options.container.classList.toggle(HIDDEN_CLASS);
      options.container.parentNode.classList.toggle(options.toggleClass);
      options.onToggleHandler();
      toggleButtonText(options);
      setState(options.container, options.componentKey);
    });
  }
};

export const isInitialStateOpen = (componentKey) => JSON.parse(localStorage.getItem(LOCALSTORAGE_COMPONENT_KEY))[componentKey] === 'open';

export const setState = (container, componentKey) => localStorage.setItem(
  LOCALSTORAGE_COMPONENT_KEY,
  JSON.stringify({ [componentKey]: isPanelClosed(container) ? 'closed' : 'open' }),
);

export const toggleButtonText = ({
  toggleButton,
  container,
  hideText,
  showText,
}) => {
  toggleButton.innerHTML = isPanelClosed(container) ? showText : hideText;
  return true;
};

export const isPanelClosed = (container) => container.classList.contains(HIDDEN_CLASS);

export const openPanel = ({ container, onOpenedHandler }) => {
  container.classList.remove(HIDDEN_CLASS);
  onOpenedHandler();
};

export const closePanel = ({ container, onClosedHandler }) => {
  container.classList.add(HIDDEN_CLASS);
  onClosedHandler();
};

const panel = {
  isInitialStateOpen,
  openPanel,
  closePanel,
};

export default panel;
