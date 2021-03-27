var MailGrabberMessageAttachment = (function() {
  /**
   * Render message attachment. Show the list of attachments at the top of the
   * message content.
   *
   * @param {Object} messageAttachments - the message attachments container
   * @param {Object} messagePart - a message part which we loaded
   */
  function render(messageAttachments, messagePart) {
    var messageAttachment = document.createElement('a');
    var fileSize = document.createElement('span');
    var messageAttachmentTemplate =
      MailGrabberDOM
        .cloneContent(
          'template[data-content-type=message-attachment-template]'
        );

    messageAttachment.href =
      'data:' + messagePart.mime_type + ';base64,' + messagePart.body;
    messageAttachment.download = messagePart.filename;
    messageAttachment.innerHTML = messagePart.filename;
    messageAttachment.classList.add('color-black', 'no-text-decoration');

    fileSize.innerHTML = MailGrabberUtilities.formatSize(messagePart.size);
    fileSize.classList.add('color-gray', 'font-size-0_9', 'padding-left-10');

    [messageAttachment, fileSize].forEach(function(node) {
      messageAttachmentTemplate
        .querySelector('li[data-content-type=message-attachment]')
        .appendChild(node);
    });

    messageAttachments.classList.remove('hide');
    messageAttachments.appendChild(messageAttachmentTemplate);
  }

  return {
    render: render
  }
})();
