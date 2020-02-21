$('.js-delete-document')
  .on('ajax:success', function(event) {
    var xhr = event.detail[2]
    var $documentRow = document.querySelector('.js-document-row[data-document-id="' + this.dataset.documentId + '"]')
    $documentRow.parentNode.removeChild($documentRow)

    if (document.querySelectorAll('.js-document-row').length === 0) {
      document.querySelector('.js-documents').classList.add('js-documents--empty')
    }

    var $errorContainer = document.querySelector('#js-xhr-flashes')
    $errorContainer.insertAdjacentHTML('beforeend', xhr.responseText)
  })
  .on('ajax:error', function() {
    $('#js-gem-c-modal-dialogue__error').show()
  })
