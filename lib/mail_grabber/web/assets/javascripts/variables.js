var MailGrabberVariables = {
  /**
   * The last message id that was loaded. If it is -1 then we have no
   * messages.
   */
  lastMessageId: -1,

  /**
   * The message has an HTML part or not.
   */
  messageHasHtmlPart: false,

  /**
   * The message list is reloading or not (click on the Reload tab).
   */
  messageListReloading: false,

  /**
   * Params that we can follow, how many messages we have on the list. We are
   * loading 15 messages in every request.
   */
  page: 1,
  perPage: 15
};
