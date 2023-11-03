import { Controller } from '@hotwired/stimulus';
import { triggerEvent } from '../../lib/events';

export default class extends Controller {
  static targets = ['source'];

  copy() {
    let text = this.sourceTarget.value ? this.sourceTarget.value : this.sourceTarget.text;
    navigator.clipboard.writeText(text);
    triggerEvent(
      'copied_to_clipboard',
      {
        description: this.sourceTarget.dataset.description,
        subject: this.sourceTarget.dataset.subject,
      },
    );
  }
}
