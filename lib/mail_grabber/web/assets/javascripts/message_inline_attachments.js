var MailGrabberMessageInlineAttachments = {
  /**
   * Render inline images of the message. Change the cid:something12345 with
   * the encoded image content.
   *
   * @param {Object} messageParts - the parts of the message
   * @param {Object} messageHtmlPart - the HTML part of the message
   *
   * @return {Object} messageHtmlPart - the modified HTML part of the message
   */
  render: function(messageParts, messageHtmlPart) {
    messageParts.forEach(function(messagePart) {
      if(messagePart.is_attachment === 1 && messagePart.is_inline === 1) {
        messageHtmlPart = messageHtmlPart.replace('cid:' + messagePart.cid,
          'data:' + messagePart.mime_type + ';base64,' + messagePart.body);
      }
    });

    return messageHtmlPart;
  }
};
