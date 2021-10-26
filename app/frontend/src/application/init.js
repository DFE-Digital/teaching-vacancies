import './jobseekers/init';
import './publishers/init';
import '../components/form/form';
import '../components/clipboard/clipboard';

const showSearchPanelEl = document.getElementById("search-panel");
const closeSearchPanelEl = document.getElementById('panel-component-close-panel');

export const togglePanel = (actionEl) => Array.from(document.getElementsByClassName('panel-component')).forEach((element) => {
  element.classList.toggle('panel-component--show-mobile') ? setPanelVisibleState(actionEl, element) : setPanelHiddenState(actionEl, element, true);
});

showSearchPanelEl.addEventListener('click', (e) => {
  togglePanel(e.target);
});

closeSearchPanelEl.addEventListener('click', () => {
  togglePanel(showSearchPanelEl);
});

export const setPanelVisibleState = (actionEl, panelEl) => {
  panelEl.focus();
  panelEl.setAttribute('aria-hidden', 'false');
  actionEl.setAttribute('aria-expanded', 'true');
};

export const setPanelHiddenState = (actionEl, panelEl, shouldFocus) => {
  if (shouldFocus) {
    actionEl.focus();
  }

  panelEl.setAttribute('aria-hidden', 'true');
  actionEl.setAttribute('aria-expanded', 'false');
};
