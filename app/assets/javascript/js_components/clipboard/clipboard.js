import { Controller } from '@hotwired/stimulus';
import { triggerEvent } from '../../lib/events';

// Brought and adapted from this project:
// https://github.com/stimulus-components/stimulus-clipboard/blob/master/src/index.ts
export default class extends Controller {
  static targets = ['button', 'source'];

  static values = {
    successContent: String,
    successDuration: {
      type: Number,
      default: 3000,
    },
  };

  copy() {
    const text = this.sourceTarget.value ? this.sourceTarget.value : this.sourceTarget.text;
    navigator.clipboard.writeText(text).then(() => this.copied());
    triggerEvent(
      'copied_to_clipboard',
      {
        description: this.sourceTarget.dataset.description,
        subject: this.sourceTarget.dataset.subject,
      },
    );
  }

  copied() {
    if (!this.hasButtonTarget) return;

    if (this.timeout) {
      clearTimeout(this.timeout);
    }
    this.originalContent = this.buttonTarget.innerHTML;
    this.buttonTarget.innerHTML = this.successContentValue;

    this.timeout = setTimeout(() => {
      this.buttonTarget.innerHTML = this.originalContent;
    }, this.successDurationValue);
  }
}
