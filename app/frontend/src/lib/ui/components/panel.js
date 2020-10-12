import 'classlist-polyfill';
import { storageAvailable } from '../../utils';
import Rollbar from '../../logging';

const LOCALSTORAGE_COMPONENT_KEY = 'panel';
const LOGGING_MESSAGE = '[Module: dashboard panel]: local storage not available';

export const togglePanel = (options) => {
  if (storageAvailable('localStorage') && !localStorage.getItem(LOCALSTORAGE_COMPONENT_KEY)) {
    localStorage.setItem(LOCALSTORAGE_COMPONENT_KEY, '{}');
    localStorage.setItem(
      LOCALSTORAGE_COMPONENT_KEY,
      JSON.stringify({ [options.componentKey]: options.defaultState }),
    );
  } else {
    Rollbar.log(LOGGING_MESSAGE);
  }

  if (options.toggleButton) {
    panel.isInitialStateOpen(options.componentKey) ? panel.openPanel(options) : panel.closePanel(options);

    toggleButtonText(options);

    options.toggleButton.addEventListener('click', () => {
      options.container.classList.toggle(options.toggleClass);
      options.onToggleHandler();
      toggleButtonText(options);
      setState(options.container, options.toggleClass, options.componentKey);
    });
  }
};

export const isInitialStateOpen = (componentKey) => JSON.parse(localStorage.getItem(LOCALSTORAGE_COMPONENT_KEY))[componentKey] === 'open';

export const setState = (container, toggleClass, componentKey) => localStorage.setItem(
  LOCALSTORAGE_COMPONENT_KEY,
  JSON.stringify({ [componentKey]: isPanelClosed(container, toggleClass) ? 'closed' : 'open' }),
);

export const toggleButtonText = ({
  toggleClass,
  toggleButton,
  container,
  hideText,
  showText,
}) => {
  toggleButton.innerHTML = isPanelClosed(container, toggleClass) ? showText : hideText;
  return true;
};

export const isPanelClosed = (container, toggleClass) => container.classList.contains(toggleClass);

export const openPanel = ({ container, toggleClass, onOpenedHandler }) => {
  container.classList.remove(toggleClass);
  onOpenedHandler();
};

export const closePanel = ({ container, toggleClass, onClosedHandler }) => {
  container.classList.add(toggleClass);
  onClosedHandler();
};

const panel = {
  isInitialStateOpen,
  openPanel,
  closePanel,
};

export default panel;
