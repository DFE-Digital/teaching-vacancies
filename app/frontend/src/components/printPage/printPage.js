import './printPage.scss';

export const initTriggerElements = (selector) => Array.from(document.querySelectorAll(selector)).forEach((el) => {
  printPage.addTriggerEvent(el);
});

export const addTriggerEvent = (el) => el.addEventListener('click', () => printPage.printHandler());

export const printHandler = () => window.print();

const printPage = {
  initTriggerElements,
  addTriggerEvent,
  printHandler,
};

export default printPage;
