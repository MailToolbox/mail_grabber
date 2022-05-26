var MailGrabberMessageList = {
  /**
   * Fill up the message list template with content.
   *
   * @param {Object} message
   *
   * @return {Object} the filled up template
   */
  fillUpTemplateWith: function(message) {
    var messageListTemplate =
      MailGrabberDOM
        .cloneContent('template[data-content-type=message-list-template]');

    messageListTemplate
      .querySelector('li')
      .addEventListener('click', function() {
        MailGrabberApplication.getMessage(message.id);
      });

    messageListTemplate
      .querySelector('div[data-content-type=message-senders]')
      .innerHTML = message.senders;

    messageListTemplate
      .querySelector('time[data-content-type=message-sent-at]')
      .innerHTML =
        MailGrabberUtilities
          .formatDateTime(message.created_at, 'messageListDateOrTime');

    messageListTemplate
      .querySelector('div[data-content-type=message-subject]')
      .innerHTML = message.subject;

    return messageListTemplate;
  },

  /**
   * Render the list of the messages. Also add event listener when click on a
   * message then it will load that content.
   *
   * @param {Object} messages - the list of the given message.
   */
  render: function(messages) {
    var messageList =
      document
        .querySelector('ul[data-content-type=message-list]');

    messages.forEach(function(message) {
      messageList.appendChild(
        MailGrabberMessageList.fillUpTemplateWith(message)
      );
    });
  }
};
