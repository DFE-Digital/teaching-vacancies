import * as mojFrontend from '@ministryofjustice/frontend';

export function initMojFrontEnd() {
  mojFrontend.initAll();

  if (typeof mojFrontend.MultiFileUpload !== 'undefined') {
    const uploadSelectors = document.querySelectorAll('.app-multi-file-upload');
    uploadSelectors.forEach((container) => {
      // eslint-disable-next-line no-new
      new mojFrontend.MultiFileUpload({
        container,
        uploadUrl: container.dataset.upload,
        deleteUrl: container.dataset.delete,
      });
    });
  }
}
