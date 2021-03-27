var MailGrabberMessageHtmlPart = {
  /**
   * Render the HTML part of the message. If the message has inline images
   * then it will render those images as well. An iframe will contain this
   * content.
   *
   * @param {Object} iFrame - the iframe HTML tag
   * @param {Object} messageParts - the parts of the message
   * @param {Object} messageHtmlPart - the HTML part of the message
   */
  render: function(iFrame, messageParts, messageHtmlPart) {
    var messageInlineAttachmentRegExp = new RegExp('cid:');

    if(messageInlineAttachmentRegExp.test(messageHtmlPart)) {
      messageHtmlPart =
        MailGrabberMessageInlineAttachments.render(
          messageParts, messageHtmlPart
        );
    }

    iFrame.srcdoc = messageHtmlPart;
    iFrame.onload = function() {
      iFrame.height = iFrame.contentDocument.body.scrollHeight + 65;
    }
  }
};
