import 'classlist-polyfill';

const LOCALSTORAGE_COMPONENT_KEY = 'panel';

export const panelToggle = (options) => {
  if (!localStorage.getItem(LOCALSTORAGE_COMPONENT_KEY)) {
    localStorage.setItem(LOCALSTORAGE_COMPONENT_KEY, '{}');
  }

  if (options.toggleButton) {
    isInitialStateOpen(options.key) ? openPanel(options.container, options.toggleClass) : closePanel(options.container, options.toggleClass);
    toggleButtonText(options);

    options.toggleButton.addEventListener('click', () => {
      options.container.classList.toggle(options.toggleClass);
      options.onToggleHandler();
      toggleButtonText(options);
      setState(options.container, options.toggleClass, options.key);
    });
  }
};

export const isInitialStateOpen = (key) => JSON.parse(localStorage.getItem(LOCALSTORAGE_COMPONENT_KEY))[key] === 'open';

export const setState = (container, toggleClass, key) => localStorage.setItem(
  LOCALSTORAGE_COMPONENT_KEY,
  JSON.stringify({ [key]: isPanelClosed(container, toggleClass) ? 'closed' : 'open' })
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

export const openPanel = (container, toggleClass) => container.classList.remove(toggleClass);

export const closePanel = (container, toggleClass) => container.classList.add(toggleClass);

export default panelToggle;
