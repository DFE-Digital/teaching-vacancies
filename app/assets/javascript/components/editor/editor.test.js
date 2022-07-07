/**
 * @jest-environment jsdom
 */

import { Application } from '@hotwired/stimulus';
import EditorController from './editor';

let application;
let controller;
let spy;

const initialiseStimulus = () => {
  application = Application.start();
  application.register('editor', EditorController);
};

const createEditorToolbar = (actions) => `<div class="editor-component__toolbar" data-editor-target="toolbar">
${Object.keys(actions).map((action) => `<button class="editor-component__toolbar-button" data-action="editor#performAction" data-editor-action="${action}"></button>`)}
</div>`;

const words = ['Three', 'little', 'piggies', 'went', 'to', 'market', 'and', 'then', 'got', 'bus', 'home'];

const getRandomWord = (firstLetterToUppercase = false) => {
  const word = words[randomNumber(0, words.length - 1)];
  return firstLetterToUppercase ? word.charAt(0).toUpperCase() + word.slice(1) : word;
};

const generateContent = (length, orphaned) => {
  const content = [...Array(length)].map((_, i) => getRandomWord(i === 0)).join(' ').trim();

  return orphaned ? content : `<p>${content}</p>`;
};

const randomNumber = (min, max) => Math.round(Math.random() * (max - min) + min);

const editorValue = generateContent(5, false);

beforeAll(() => {
  document.body.innerHTML = `<div class="editor-component" data-controller="editor">
  <label data-action="click->editor#focus" for="">Editor label text</label>
  <div class="govuk-hint" id="editor-hint">Editor hint text</div>
  ${createEditorToolbar(EditorController.TOOLBAR_ACTIONS)}
  <div class="editor-component__content" contenteditable="true" data-action="input->editor#update paste->editor#handlePaste blur->editor#tidy" data-editor-target="editor">${editorValue}</div>
  <div class="editor-component__form-input" data-editor-target="formInput">
  <textarea name="input-test" id="input-test"></textarea>
  </div>
  </div>`;

  document.execCommand = jest.fn();
  spy = jest.spyOn(document, 'execCommand');

  initialiseStimulus();
});

describe('Content editable form control', () => {
  beforeEach(() => {
    controller = application.getControllerForElementAndIdentifier(document.querySelector('[data-controller="editor"]'), 'editor');
    controller.enabled = true;
  });

  it('should set correct a11y attributes', () => {
    expect(document.getElementById('input-test').getAttribute('tabindex')).toBe('-1');
    expect(document.getElementById('input-test').getAttribute('aria-hidden')).toBe('true');
  });

  it('should set form input value when component is first rendered', () => {
    expect(document.getElementById('input-test').value).toBe(EditorController.contentWrapper(editorValue));
  });

  it('should update hidden form input value when user updates content', () => {
    const newEditorValue = `${editorValue}${generateContent(5, false)}`;
    controller.editorTarget.innerHTML = newEditorValue;
    controller.editorTarget.dispatchEvent(new Event('input'));
    expect(document.getElementById('input-test').value).toBe(EditorController.contentWrapper(newEditorValue));
  });

  it('should call command for associated toolbar action', () => {
    controller.toolbarTarget.querySelector('[data-editor-action="ul"]').click();
    expect(spy).toHaveBeenNthCalledWith(2, EditorController.TOOLBAR_ACTIONS.ul, false, null);
  });

  it('should put focus on editor input area when clicking label', () => {
    controller.element.querySelector('label').click();
    expect(document.activeElement).toBe(controller.editorTarget);
  });

  it('should output content with one content custom element', () => {
    expect(EditorController.contentWrapper('<editor-content>test</editor-content>')).toBe('<editor-content>test</editor-content>');
  });

  it('should remove unwanted HTML attributes when content is pasted', () => {
    expect(EditorController.sanitize('<ul style="color:red"><li></li></ul>').querySelectorAll('ul[style="color:red"]').length).toBe(0);
    expect(EditorController.sanitize('<ul class="not-wanted"><li></li></ul>').querySelectorAll('ul.not-wanted').length).toBe(0);
    expect(EditorController.sanitize('<ul id="dont-want"><li></li></ul>').querySelectorAll('ul#dont-want').length).toBe(0);
    expect(EditorController.sanitize('<ul aria-label="moo"><li></li></ul>').querySelectorAll('ul[aria-label="moo"]').length).toBe(0);
  });

  it('should escape unwanted HTML tags when content is pasted', () => {
    expect(EditorController.sanitize('<div><script></script></div>').querySelectorAll('script').length).toBe(0);
    expect(EditorController.sanitize('<p><strong>text</strong></p>').querySelectorAll('strong').length).toBe(0);
    expect(EditorController.sanitize('<ul><li></li></ul>').querySelectorAll('ul li').length).toBe(1);
  });

  it('should replace bullet characters with html list', () => {
    controller.editorTarget.innerHTML = '<p>para text</p><p>• 1</p><p>● 2</p><p>para text 2</p><p>· 3</p>';
    controller.replaceBullets();
    expect(controller.editorTarget.innerHTML).toBe('<p>para text</p><ul><li>1</li><li>2</li></ul><p>para text 2</p><ul><li>3</li></ul>');
  });

  it('should remove empty paragraph tags', () => {
    controller.editorTarget.innerHTML = '<p>para text</p><p></p><p>para text 2</p><p></p>';
    controller.removeEmptyParagraphs();
    expect(controller.editorTarget.innerHTML).toBe('<p>para text</p><p>para text 2</p>');
  });

  it('should wrap orphaned text nodes in paragraph tag', () => {
    const newEditorValue = EditorController.contentWrapper(`${generateContent(5, true)}`);
    controller.editorTarget.innerHTML = newEditorValue;
    controller.wrapOrphanedText();
    expect(controller.editorTarget.innerHTML).toBe(EditorController.contentWrapper(`<p>${newEditorValue}</p>`));
  });
});
