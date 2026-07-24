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
    const { editor } = this.editorTarget;
    if (!editor) return 0;

    return this.constructor.countWordsInText(editor.getDocument().toString());
  }

  displayCount(wordCount) {
    const formattedCount = this.constructor.formatNumber(wordCount);
    const formattedMax = this.constructor.formatNumber(this.maxWordsValue);
    const message = `You have written ${formattedCount} words. `
      + `The word limit is ${formattedMax} words. `
      + 'Schools typically expect personal statements to be 500 to 1,000 words.';
    this.counterTarget.textContent = message;
  }

  static formatNumber(num) {
    return num >= 1000 ? num.toLocaleString('en-GB') : num.toString();
  }

  static countWordsInText(text) {
    const trimmedText = text.trim();
    if (trimmedText.length === 0) return 0;

    return trimmedText.split(/\s+/).length;
  }
}
