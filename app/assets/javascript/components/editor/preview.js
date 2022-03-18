import { Controller } from '@hotwired/stimulus';

const EditorPreviewController = class extends Controller {
  static targets = ['debugPreview'];

  update({ detail }) {
    this.debugPreviewTarget.innerText = detail.content;
  }
};

export default EditorPreviewController;
