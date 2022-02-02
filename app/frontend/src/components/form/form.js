import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['inputText'];

  submitListener(e) {
    this.formEl = e.target;
    this.submitHandler();
  }

  submitHandler() {
    this.formEl.closest('form').submit();
  }

  clearListener(e) {
    this.inputTextTargets.forEach((inputTextTarget) => {
      this.clearHandler(inputTextTarget, e.target.checked);
    });
  }

  clearHandler(el, checked) {
    this.fields = Array.from(el.querySelectorAll('input[type="text"]'));
    if (checked) {
      this.disableInputs();
    } else {
      this.enableInputs();
    }
  }

  enableInputs() {
    this.fields.forEach((input) => {
      input.disabled = false;
      input.value = input.getAttribute('value');
    });
  }

  disableInputs() {
    this.fields.forEach((input) => {
      input.value = '';
    });
  }
}
