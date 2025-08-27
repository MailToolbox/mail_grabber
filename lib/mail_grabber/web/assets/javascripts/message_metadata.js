var MailGrabberMessageMetadata = {
  /**
   * Render senders' and recipients' data of the message.
   *
   * @param {Object} messageMetadata - the metadata container
   * @param {Object} message - the requested message
   */
  render: function(messageMetadata, message) {
    var metadata =
      '<dt>From:</dt><dd>' + message.senders + '</dd>' +
      '<dt>To:</dt><dd>' + message.recipients + '</dd>';

    if(message.carbon_copy) {
      metadata += '<dt>Cc:</dt><dd>' + message.carbon_copy + '</dd>';
    }

    if(message.blind_carbon_copy) {
      metadata += '<dt>Bcc:</dt><dd>' + message.blind_carbon_copy + '</dd>';
    }

    messageMetadata.innerHTML = metadata;
  }
};
