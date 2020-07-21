/* eslint-disable */
import { nodeListForEach } from 'govuk-frontend/govuk/common';

window.GOVUK = window.GOVUK || {};
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function DeleteDocumentConfirmationDialogue() { }

  DeleteDocumentConfirmationDialogue.prototype.start = function ($module) {
    this.$module = $module[0];
    this.$dialogBox = this.$module.querySelector('.gem-c-modal-dialogue__box');
    this.$closeButton = this.$module.querySelector('.gem-c-modal-dialogue__close-link');
    this.$html = document.querySelector('html');
    this.$body = document.querySelector('body');

    this.$module.resize = this.handleResize.bind(this);
    this.$module.open = this.handleOpen.bind(this);
    this.$module.close = this.handleClose.bind(this);
    this.$module.focusDialog = this.handleFocusDialog.bind(this);
    this.$module.boundKeyDown = this.handleKeyDown.bind(this);

    const $triggerElements = document.querySelectorAll(
      `[data-toggle="modal"][data-target="${this.$module.id}"]`,
    );

    const $element = this;

    nodeListForEach($triggerElements, ($triggerElement) => {
      $triggerElement.addEventListener('click', $element.$module.open);
    });

    if (this.$closeButton) {
      this.$closeButton.addEventListener('click', this.$module.close);
    }
  };

  DeleteDocumentConfirmationDialogue.prototype.handleResize = function (size) {
    if (size === 'narrow') {
      this.$dialogBox.classList.remove('gem-c-modal-dialogue__box--wide');
    }

    if (size === 'wide') {
      this.$dialogBox.classList.add('gem-c-modal-dialogue__box--wide');
    }
  };

  DeleteDocumentConfirmationDialogue.prototype.handleOpen = function (event) {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }

    this.$html.classList.add('gem-o-template--modal');
    this.$body.classList.add('gem-o-template__body--modal');
    this.$body.classList.add('gem-o-template__body--blur');

    const $target = event.target;

    this.$dialogBox.querySelector('#js-gem-c-modal-dialogue__file-name').innerText = $target.dataset.fileName;
    this.$dialogBox.querySelector('#js-gem-c-modal-dialogue__confirm-action').setAttribute('href', $target.dataset.deletePath);
    this.$dialogBox.querySelector('#js-gem-c-modal-dialogue__confirm-action').dataset.documentId = $target.dataset.documentId;
    this.$dialogBox.querySelector('#js-gem-c-modal-dialogue__error').style.display = 'none';

    this.$focusedElementBeforeOpen = document.activeElement;
    this.$module.style.display = 'block';
    this.$dialogBox.focus();

    document.addEventListener('keydown', this.$module.boundKeyDown, true);
  };

  DeleteDocumentConfirmationDialogue.prototype.handleClose = function (event) {
    if (event) {
      event.preventDefault();
    }

    this.$html.classList.remove('gem-o-template--modal');
    this.$body.classList.remove('gem-o-template__body--modal');
    this.$body.classList.remove('gem-o-template__body--blur');
    this.$module.style.display = 'none';
    this.$focusedElementBeforeOpen.focus();

    document.removeEventListener('keydown', this.$module.boundKeyDown, true);
  };

  DeleteDocumentConfirmationDialogue.prototype.handleFocusDialog = function () {
    this.$dialogBox.focus();
  };

  // while open, prevent tabbing to outside the dialogue
  // and listen for ESC key to close the dialogue
  DeleteDocumentConfirmationDialogue.prototype.handleKeyDown = function (event) {
    const KEY_TAB = 9;
    const KEY_ESC = 27;

    switch (event.keyCode) {
      case KEY_TAB:
        if (event.shiftKey) {
          if (document.activeElement === this.$dialogBox) {
            event.preventDefault();
            this.$closeButton.focus();
          }
        } else if (document.activeElement === this.$closeButton) {
          event.preventDefault();
          this.$dialogBox.focus();
        }

        break;
      case KEY_ESC:
        this.$module.close();
        break;
      default:
        break;
    }
  };

  Modules.DeleteDocumentConfirmationDialogue = DeleteDocumentConfirmationDialogue;
}(window.GOVUK.Modules));

$(document).ready(() => {
  const $deleteDocumentConfirmationDialogue = $('[data-module="file-remove-confirmation-dialogue"]');

  $deleteDocumentConfirmationDialogue.each(function () {
    (new window.GOVUK.Modules.DeleteDocumentConfirmationDialogue()).start($(this));
  });
});

$('#js-gem-c-modal-dialogue__confirm-action')
  .on('ajax:beforeSend', function () {
    $('#js-gem-c-modal-dialogue__error').hide();
    $(this).addClass('govuk-button--disabled');
  })
  .on('ajax:success', function (event) {
    const xhr = event.detail[2];
    const $documentRow = document.querySelector(`.js-document-row[data-document-id="${this.dataset.documentId}"]`);
    $documentRow.parentNode.removeChild($documentRow);

    if (document.querySelectorAll('.js-document-row').length === 0) {
      document.querySelector('.js-documents').classList.add('js-documents--empty');
    }

    const $errorContainer = document.querySelector('#js-xhr-flashes');
    $errorContainer.insertAdjacentHTML('beforeend', xhr.responseText);

    document.querySelector('[data-module="file-remove-confirmation-dialogue"]').close();
  })
  .on('ajax:error', () => {
    $('#js-gem-c-modal-dialogue__error').show();
  })
  .on('ajax:complete', function () {
    $(this).removeClass('govuk-button--disabled');
  });
