import { Controller } from '@hotwired/stimulus';
import { triggerEvent } from '../../lib/events';

export default class extends Controller {
  static targets = ['source'];

  copy() {
    this.sourceTarget.select();
    document.execCommand('copy');
    triggerEvent(
      'copied_to_clipboard',
      {
        description: this.sourceTarget.dataset.description,
        subject: this.sourceTarget.dataset.subject,
      },
    );
  }
}
