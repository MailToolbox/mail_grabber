var MailGrabberMessageContent = {
  /**
   * Fill up the message content template with content.
   *
   * @param {Object} response - from the server with data
   *
   * @return {Object} the filled up template
   */
  fillUpTemplateWith: function(response) {
    var message = response.message;
    var messageParts = response.message_parts;
    var messageContentTemplate =
      MailGrabberDOM
        .cloneContent('template[data-content-type=message-content-template]');

    messageContentTemplate
      .querySelector('div[data-content-type=message-subject]')
      .innerHTML = message.subject;

    messageContentTemplate
      .querySelector('dl[data-content-type=metadata]')
      .innerHTML = MailGrabberMessageMetadata.render(message);

    messageContentTemplate
      .querySelector('time[data-content-type=message-sent-at]')
      .innerHTML = MailGrabberUtilities.formatDateTime(message.created_at);

    messageContentTemplate
      .querySelectorAll('[data-message-tab]')
      .forEach(function(tab) {
        tab.addEventListener('click', MailGrabberDOM.changeMessageContent);
      });

    messageContentTemplate
      .querySelector('li[data-content-type=message-delete-tab]')
      .addEventListener('click', function() {
        MailGrabberApplication.deleteMessage(message.id);
      });

    messageContentTemplate
      .querySelector('li[data-content-type=message-close-tab]')
      .addEventListener('click', MailGrabberDOM.defaultBackground);

    messageParts.forEach(function(messagePart) {
      if(messagePart.is_attachment === 0 && messagePart.is_inline === 0) {
        switch(messagePart.mime_type) {
          case 'text/html':
            MailGrabberVariables.messageHasHtmlPart = true;
            MailGrabberMessageHtmlPart.render(
              messageContentTemplate
                .querySelector('iframe[data-content-type=message-html-body]'),
              messageParts,
              messagePart.body
            );

            break;
          case 'text/plain':
            messageContentTemplate
              .querySelector('pre[data-content-type=message-text-body]')
              .innerText = messagePart.body;

            break;
        }
      } else if(messagePart.is_attachment === 1 &&
                messagePart.is_inline === 0) {
        MailGrabberMessageAttachment.render(
          messageContentTemplate
            .querySelector('ul[data-content-type=message-attachments]'),
          messagePart
        );
      }
    });

    messageContentTemplate
      .querySelector('pre[data-content-type=message-raw-body]')
      .innerText = message.raw;

    return messageContentTemplate;
  },

  /**
   * Render the content of the message (all parts, inline attachments and
   * attachments). Also it sets up event listeners of the HTML, PlainText,
   * Raw, Delete and Close tabs.
   *
   * @param {Object} response - the response of the get message request
   */
  render: function(response) {
    var messageContent =
      document
        .querySelector('div[data-content-type=message-content]');

    messageContent.removeAttribute('style');
    messageContent.innerHTML = '';

    MailGrabberVariables.messageHasHtmlPart = false;

    messageContent.appendChild(
      MailGrabberMessageContent.fillUpTemplateWith(response)
    );

    if(!MailGrabberVariables.messageHasHtmlPart) {
      messageContent
        .querySelector('li[data-message-tab=text]')
        .click();

      messageContent
        .querySelector('li[data-message-tab=html]')
        .classList.add('hide');
    }
  }
};
