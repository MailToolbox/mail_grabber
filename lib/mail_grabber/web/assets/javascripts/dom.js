var MailGrabberDOM = {
  /**
   * Change which content (message part) should show. When the page is loading,
   * the HTML content will be active and the others will be hidden. When we
   * click on tab e.g. Plain Text then this content will be active and other
   * hidden.
   *
   * @param {Object} event - which part we clicked
   */
  changeMessageContent: function(event) {
    var messageTabs =
      document
        .querySelectorAll('[data-message-tab]');

    var messageContents =
      document
        .querySelectorAll('[data-message-content]');

    var clickedTabType = event.target.dataset.messageTab;

    messageTabs.forEach(function(messageTab, index) {
      messageTab.classList.remove('active');
      messageContents[index].classList.remove('hide');

      if(messageTab.dataset.messageTab === clickedTabType) {
        messageTab.classList.add('active');
      }

      if(messageContents[index].dataset.messageContent !== clickedTabType) {
        messageContents[index].classList.add('hide');
      }
    });
  },

  /**
   * Create a clone from an element, e.g. template tag.
   *
   * @param {String} selector - which describe how to find the element
   *
   * @return {Object} the clone of the found element
   */
  cloneContent: function(selector) {
    return document.querySelector(selector).content.cloneNode(true);
  },

  /**
   * Show default background image instead of any content.
   */
  defaultBackground: function() {
    var messageContent =
      document
        .querySelector('div[data-content-type=message-content]');

    messageContent.innerHTML = '';

    messageContent.style.background =
      "url('" + messageContent.dataset.backgroundImage +
      "') center center no-repeat";
    messageContent.style.backgroundSize = '50%';
    messageContent.style.opacity = '10%';
  },

  /**
   * Delete all content (message list and message content as well),
   * set default background and the infinite scroll params when we click on
   * the Reload or Delete tabs.
   */
  deleteContent: function() {
    MailGrabberVariables.lastMessageId = -1;
    MailGrabberVariables.page = 1;
    MailGrabberDOM.defaultBackground();

    document
      .querySelector('ul[data-content-type=message-list]')
      .innerHTML = '';
  },

  /**
   * Root path, which returns with the server's root path. It can be an empty
   * string or a string. It depends on how the server is running (standalone
   * or in Ruby on Rails).
   */
  rootPath: function() {
    return document.querySelector('body').dataset.rootPath;
  }
};
