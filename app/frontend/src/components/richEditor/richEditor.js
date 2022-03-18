import './richEditor.scss';

import { Controller } from '@hotwired/stimulus';
import DOMPurify from 'dompurify';

// see https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/Editable_content for lots of
// interesting/tedious (delete as appropriate) background information.
const RichEditorController = class extends Controller {
  static targets = ['editor', 'debugPreview'];

  connect() {
    // Ensure paragraphs are created instead of divs
    // TODO: This is deprecated - what should we do instead?
    document.execCommand('defaultParagraphSeparator', false, 'p');

    // Initial setting of the debug preview
    this.updateDebugPreview();
  }

  handlePaste(event) {
    const { types } = event.clipboardData;

    // Sanitise if what's being pasted is HTML, otherwise let the browser get on with default
    // behaviour
    if (((types instanceof DOMStringList) && types.contains('text/html')) || (types.indexOf && types.indexOf('text/html') !== -1)) {
      // Don't let the browser paste it for us
      event.preventDefault();

      // Get and clean the HTML data from the clipboard
      const html = event.clipboardData.getData('text/html');
      const cleanFragment = DOMPurify.sanitize(html, {
        ALLOWED_TAGS: ['p', 'ul', 'li', '#text'],
        ALLOWED_ATTR: [],
        RETURN_DOM_FRAGMENT: true,
      });

      // Insert the text at the selection point, overwriting any potentially existing selection
      const selection = window.getSelection();
      if (!selection.rangeCount) return; // Shouldn't happen: pasting without a cursor in the field
      selection.deleteFromDocument();
      selection.getRangeAt(0).insertNode(cleanFragment);
    }

    // Post-paste tidy up
    this.tidy();

    // Always update the debug preview after pasting
    this.updateDebugPreview();
  }

  tidy() {
    // Fix any orphaned top-level text nodes by wrapping them in a <p>
    const orphanedTextNodes = Array.from(this.editorTarget.childNodes).filter((n) => n.nodeType === 3);
    orphanedTextNodes.forEach((node) => {
      const para = document.createElement('p');
      para.textContent = node.textContent;

      this.editorTarget.replaceChild(para, node);
    });

    // Remove empty paragraphs
    const paragraphs = this.editorTarget.querySelectorAll('p');
    paragraphs.forEach((p) => {
      if (p.textContent.trim().length > 0) return;
      this.editorTarget.removeChild(p);
    });

    // Fix excessively nested paragraphs
    // TODO

    // Always update the debug preview after tidying
    this.updateDebugPreview();
  }

  insertList() {
    document.execCommand("insertUnorderedList", false, null);
  }

  // Updates the debug preview to show the raw HTML content of the editor field
  // TODO: Remove this method when productionising the component
  updateDebugPreview() {
    this.debugPreviewTarget.innerText = this.editorTarget.innerHTML;
  }
};

export default RichEditorController;
