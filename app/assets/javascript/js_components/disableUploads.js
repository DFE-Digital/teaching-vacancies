import { Controller } from '@hotwired/stimulus';

// https://www.donnfelker.com/disable-attachments-in-the-trix-editor/
export default class extends Controller {
  // eslint-disable-next-line class-methods-use-this
  connect() {
    // Disable trix uploads: https://github.com/basecamp/trix/issues/604#issuecomment-600974875
    // Get rid of the upload button
    document.addEventListener('trix-initialize', () => {
      const fileTools = document.querySelector('.trix-button-group--file-tools');
      // null check hack: trix-initialize gets called twice for some reason, sometimes it is null :shrug:
      fileTools?.remove();
    });
    // Don't allow images/etc to be pasted
    document.addEventListener('trix-attachment-add', (event) => {
      if (!event.attachment.file) {
        event.attachment.remove();
      }
    });
    // No files, ever
    document.addEventListener('trix-file-accept', (event) => {
      event.preventDefault();
    });
  }
}
