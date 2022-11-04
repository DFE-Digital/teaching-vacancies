import { Controller } from '@hotwired/stimulus';
import DOMPurify from 'dompurify';

const EditorController = class extends Controller {
  static targets = ['editor', 'toolbar', 'formInput'];

  static TOOLBAR_ACTIONS = {
    ul: 'insertUnorderedList',
  };

  static ALLOWED_TAGS = ['p', 'ul', 'li', '#text'];

  connect() {
    this.enabled = true;

    // this will disable IE11
    if (typeof window.ClipboardEvent === 'undefined') {
      this.enabled = false;
      this.editorTarget.addEventListener('keydown', () => {
        this.update();
      });
    } else {
      this.toolbarTarget.style.display = 'block';
    }

    // Ensure paragraphs are created instead of divs
    document.execCommand('defaultParagraphSeparator', false, 'p');

    this.formInput = this.formInputTarget.querySelector('textarea');
    this.formInput.setAttribute('aria-hidden', true);
    this.formInput.setAttribute('tabindex', '-1');

    // move editable area next to texarea so error styles applied correctly
    const editableArea = this.formInputTarget.querySelector('.editor-component__content-container');
    const editableAreaHhtml = editableArea.innerHTML;
    editableArea.remove();
    this.formInput.insertAdjacentHTML('beforeBegin', editableAreaHhtml);

    this.update();
  }

  handlePaste(event) {
    if (this.enabled) {
      const { types } = event.clipboardData;

      if (((types instanceof DOMStringList) && types.contains('text/html')) || (types.indexOf && types.indexOf('text/html') !== -1)) {
        event.preventDefault(); // prevent default browser paste

        EditorController.insert(
          EditorController.sanitize(event.clipboardData.getData('text/html')),
        );
      }
    }

    this.removeEmptyParagraphs();
    this.removeNbsp();
    this.replaceBullets();
    this.wrapOrphanedText();

    this.update();
  }

  static sanitize(clipboardData) {
    return DOMPurify.sanitize(clipboardData, {
      ALLOWED_TAGS: EditorController.ALLOWED_TAGS,
      FORBID_TAGS: ['link', 'script', 'strong', 'br', 'font'],
      FORBID_ATTR: ['style', 'font', 'dir', 'role', 'class', 'id', 'align'],
      ALLOW_ARIA_ATTR: false,
      RETURN_DOM_FRAGMENT: true,
    });
  }

  static insert(cleanFragment) {
    // Insert the text at the selection point, overwriting any potentially existing selection
    const selection = window.getSelection();
    if (!selection.rangeCount) return; // Shouldn't happen: pasting without a cursor in the field
    selection.deleteFromDocument();
    selection.getRangeAt(0).insertNode(cleanFragment);
  }

  removeEmptyParagraphs() {
    const paragraphs = this.editorTarget.querySelectorAll('p');

    paragraphs.forEach((p) => {
      if (p.textContent.trim().length > 0) return;
      p.parentNode.removeChild(p);
    });
  }

  wrapOrphanedText() {
    // Wrap any orphaned top-level text nodes in a <p> tag
    let [c] = this.editorTarget.getElementsByTagName('editor-content');

    if (!c) c = this.editorTarget;

    if (c && c.childNodes.length) {
      const orphanedTextNodes = Array.from(c.childNodes).filter((n) => n.nodeType === 3);
      orphanedTextNodes.forEach((node) => {
        const paragraphEl = document.createElement('p');
        paragraphEl.textContent = node.textContent;
        c.replaceChild(paragraphEl, node);
      });
    }
  }

  focus() {
    this.editorTarget.focus();
  }

  removeNbsp() {
    this.editorTarget.innerHTML = this.editorTarget.innerHTML.replace(/&nbsp;/g, '');
  }

  replaceBullets() {
    let ul = null;
    const bulletUnicode = '\u2022';
    const bulletOperatorUnicode = '\u00B7';
    const blackCircleUnicode = '\u25CF';
    const bulletUnicodes = [bulletUnicode, bulletOperatorUnicode, blackCircleUnicode];
    const replace = new RegExp(`(${bulletUnicodes.join('|')})`);

    Array.from(this.editorTarget.getElementsByTagName('p')).forEach((node) => {
      if (bulletUnicodes.filter((bu) => node.textContent.charAt(0) === bu).length > 0) {
        if (!ul) {
          ul = document.createElement('ul');
          node.parentNode.insertBefore(ul, node.nextSibling);
        }

        ul.insertAdjacentHTML('beforeend', `<li>${node.textContent.replace(replace, '').trim()}</li>`);
        node.parentNode.removeChild(node);
      } else {
        ul = null;
      }
    });
  }

  static contentWrapper = (content) => {
    const strippedContent = content.replace('<editor-content>', '').replace('</editor-content>', '');
    return strippedContent;
  };

  wordCount(content) {
    const strippedContent = content.replace(/<(.|\n)*?>/g, ' ');
    const numberwords = strippedContent.trim().split(/\s+/);

    let message;

    if (numberwords.length > 300) {
      message = `You have ${numberwords.length - 300} words too many`;
      this.wordCountErrorState();
    } else if (numberwords.length <= 300 && numberwords[0].length > 0) {
      message = `You have ${300 - numberwords.length} words remaining`;
      this.wordCountDefaultState();
    } else {
      message = 'You have 300 words remaining';
      this.wordCountDefaultState();
    }

    this.wordCountSetMessage(message);
  }

  wordCountErrorState() {
    this.formInputTarget.querySelector('div.govuk-character-count__message').classList.add('govuk-error-message');
    this.formInputTarget.querySelector('div.govuk-character-count__message').classList.remove('govuk-hint');
  }

  wordCountDefaultState() {
    this.formInputTarget.querySelector('div.govuk-character-count__message').classList.remove('govuk-error-message');
    this.formInputTarget.querySelector('div.govuk-character-count__message').classList.add('govuk-hint');
  }

  wordCountSetMessage(message) {
    this.formInputTarget.querySelector('div.govuk-character-count__message').innerHTML = message;
  }

  update() {
    this.formInput.value = this.editorTarget.innerHTML.replace(/&nbsp;/g, '');

    if (this.formInputTarget.querySelector('div.govuk-character-count__message')) {
      this.wordCount(this.editorTarget.innerHTML);
    }

    // dispatch event for other components to listen to e.g editor debug/preview
    if (this.enabled) {
      this.dispatch('update', {
        detail: { content: this.editorTarget.innerHTML },
      });
    }
  }

  performAction(event) {
    const action = EditorController.TOOLBAR_ACTIONS[event.target.dataset.editorAction];
    document.execCommand(action, false, null);
    this.update();
  }
};

export default EditorController;
