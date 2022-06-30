import * as Turbo from '@hotwired/turbo';

Turbo.start();

let activeId;

document.addEventListener('turbo:submit-start', () => {
  activeId = document.activeElement.id;
});

document.addEventListener('turbo:frame-load', () => {
  if (activeId) {
    document.getElementById(activeId).focus();
  }
});
