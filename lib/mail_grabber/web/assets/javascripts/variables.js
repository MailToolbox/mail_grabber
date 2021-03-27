var MailGrabberVariables = (
  function() {
    return {
      /**
       * The last message id what loaded. If it is -1 then we have no any
       * messages.
       */
      lastMessageId: -1,

      /**
       * The message has HTML part or not.
       */
      messageHasHtmlPart: false,

      /**
       * The message is list reloading or not (click on the Reload tab).
       */
      messageListReloading: false,

      /**
       * Params that we can follow how many messages we have on the list. We are
       * loading 15 messages in every requests.
       */
      page: 1,
      perPage: 15
    }
  }
)();
