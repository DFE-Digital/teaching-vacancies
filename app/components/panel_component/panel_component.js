window.addEventListener(
  'DOMContentLoaded',
  () => init(),
);

export const init = () => {
  Array.from(document.getElementsByClassName('panel-component__toggle')).forEach((actionEl) => {
    const panelContainerEl = document.getElementById(actionEl.dataset.panelId);
    const closePanelEl = panelContainerEl.getElementsByClassName('panel-component__close-button')[0];

    actionEl.addEventListener('click', (e) => {
      togglePanel(e.target);
    });

    closePanelEl.addEventListener('click', () => {
      togglePanel(actionEl);
    });

    panelContainerEl.addEventListener('keydown', (e) => {
      if (['Esc', 'Escape'].includes(e.key)) {
        panelContainerEl.classList.remove('panel-component--visible');
        setPanelHiddenState(actionEl, panelContainerEl, true);
      }
    });
  });
};

export const togglePanel = (actionEl) => Array.from(document.getElementsByClassName('panel-component')).forEach((element) => {
  element.classList.toggle('panel-component--visible') ? setPanelVisibleState(actionEl, element) : setPanelHiddenState(actionEl, element, true);
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
