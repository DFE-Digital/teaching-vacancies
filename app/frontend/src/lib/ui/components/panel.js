import 'classlist-polyfill';

export const panelToggle = (options) => {
  if (options.toggleButton) {
    options.toggleButton.addEventListener('click', () => {
      options.container.classList.toggle(options.toggleClass);
      options.onToggleHandler();
      toggleButtonText(options);
    });
  }
};

export const toggleButtonText = ({
  toggleClass,
  toggleButton,
  container,
  hideText,
  showText,
}) => toggleButton.innerHTML = isPanelClosed(container, toggleClass) ? showText : hideText;

export const isPanelClosed = (container, toggleClass) => container.classList.contains(toggleClass);

export default panelToggle;
