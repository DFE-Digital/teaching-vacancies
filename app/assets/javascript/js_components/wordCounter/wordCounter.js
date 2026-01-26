import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['editor', 'counter'];

  static values = {
    maxWords: { type: Number, default: 1500 },
  };

  connect() {
    this.boundUpdateCount = this.updateCount.bind(this);
    this.editorTarget.addEventListener('trix-initialize', this.boundUpdateCount);
    this.editorTarget.addEventListener('trix-change', this.boundUpdateCount);
  }

  disconnect() {
    this.editorTarget.removeEventListener('trix-initialize', this.boundUpdateCount);
    this.editorTarget.removeEventListener('trix-change', this.boundUpdateCount);
  }

  updateCount() {
    const wordCount = this.countWords();
    this.displayCount(wordCount);
  }

  countWords() {
    const { editor } = this.editorTarget.editor;
    if (!editor) return 0;

    const text = editor.getDocument().toString().trim();
    if (text.length === 0) return 0;

    const words = text.split(/\s+/).filter((word) => word.length > 0);
    return words.length;
  }

  displayCount(wordCount) {
    this.counterTarget.textContent = `You have used ${wordCount} of ${this.maxWordsValue} words`;
  }
}
