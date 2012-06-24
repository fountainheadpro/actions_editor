actions_editor
==============

intuitive wysiwyg wiki editor focused on social sharing and publishing.

Version 0.1:

Supports the following features:
1. Link processing.
After user paste or types a url, the url is converted to the page link with the page title.
Backend component currently uses mechanize gem to extract title by link.

2. Image processing
If the user pastes the image from clipboard or a link to the image, it translated to the embeded imaged in the fly.

3. HTML processing.
Currenlty it allows the user to paste HTML. It will strip off styling, but will keep the structure intact.