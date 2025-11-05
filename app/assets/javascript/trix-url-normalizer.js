export function initTrixURLNormalizer() {
  document.addEventListener('trix-initialize', () => {
    const trixToolbar = document.querySelector('trix-toolbar');

    // Make toolbar buttons keyboard accessible by removing tabindex="-1"
    const toolbarButtons = trixToolbar.querySelectorAll('button[tabindex="-1"]');
    toolbarButtons.forEach((button) => {
      button.removeAttribute('tabindex');
    });

    const normalizeWebEmbedURL = () => {
      const url = urlInput.value.trim();
      // return when no value
      if (!url) return;

      // Don't modify if URL already has a protocol
      if (/^[a-z]+:\/\//.test(url)) {
        return;
      }

      // Add HTTP to URLs without a protocol
      urlInput.value = `http://${url}`;
    };

    // Add default protocol when `Click` link button
    const linkButton = trixToolbar.querySelector('.trix-dialog--link [value="Link"]');
    linkButton.addEventListener('click', normalizeWebEmbedURL);

    // Add default protocol when `Enter` key pressed down
    const urlInput = trixToolbar.querySelector('.trix-dialog--link [type="url"]');
    urlInput.addEventListener('keydown', (e) => {
      if (e.keyCode === 13) { // Enter key
        normalizeWebEmbedURL();
      }
    });
  });
}
