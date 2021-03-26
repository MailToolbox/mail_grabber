var MailGrabberApplication = (
  function() {
    /**
     * Delete a message when we click on the Delete tab. It will remove all
     * content and reload the message list.
     *
     * @param {Number} messageId - which message we would like to delete
     */
    function deleteMessage(messageId) {
      request('DELETE', '/message/' + messageId + '.json', function() {
        MailGrabberDOM.deleteContent();
        getMessageList();
      });
    }

    /**
     * Delete message list when we click on the Clear tab. It will remove
     * everything.
     */
    function deleteMessageList() {
      request('DELETE', '/messages.json', function() {
        MailGrabberDOM.deleteContent();
      });
    }

    /**
     * Get a message and render the message content, when we click on an item
     * from the message list.
     *
     * @param {Number} messageId - which message we would like to see
     */
    function getMessage(messageId) {
      request('GET', '/message/' + messageId + '.json', function(response) {
        MailGrabberMessageContent.render(JSON.parse(response));
      });
    }

    /**
     * Get a list of the messages. Also change the params of the infinite scroll
     * that we can know which page we are on. It checks the message ids to not
     * load those messages which are already on the list.
     */
    function getMessageList() {
      var messageIds;

      request('GET', '/messages.json?page=' + MailGrabberVariables.page +
        '&per_page=' + MailGrabberVariables.perPage, function(response) {
        response = JSON.parse(response);
        messageIds = response.map(function(hash) { return hash['id'] });

        if(response.length > 0) {
          if(messageIds.indexOf(MailGrabberVariables.lastMessageId) === -1) {
            MailGrabberVariables.lastMessageId = messageIds.pop();
            MailGrabberVariables.page++;
            MailGrabberMessageList.render(response);
          } else {
            reloadMessageList();
          }
        }
      });
    }

    /**
     * Scrolling infinitely. Count the height of the list and if we reached the
     * bottom of the list then tries to load more message.
     *
     * @param {Object} messageList - the message list container
     */
    function infiniteScroll(messageList) {
      var scrollHeight = messageList.scrollHeight;
      var scrollTop = messageList.scrollTop;
      var clientHeight = messageList.clientHeight;

      if(scrollHeight - scrollTop === clientHeight) {
        getMessageList();
      }
    }

    /**
     * Initialize MailGrabber. Add some event listeners to the Reload and the
     * Clear tabs then load messages and the default background.
     */
    function init() {
      document
        .querySelector('li[data-content-type=message-reload-tab]')
        .addEventListener('click', reloadMessageList);

      document
        .querySelector('li[data-content-type=message-clear-tab]')
        .addEventListener('click', deleteMessageList);

      loadMessageList();
      MailGrabberDOM.defaultBackground();
    }

    /**
     * Load the message list. Also add event listener for infinite scroll.
     */
    function loadMessageList() {
      var messageList =
        document
          .querySelector('ul[data-content-type=message-list]');

      messageList.addEventListener('scroll', function() {
        infiniteScroll(messageList);
      });

      getMessageList();
    }

    /**
     * Reload the message list. When we have new messages in the database, but
     * we scrolled down or clicked on the Reload tab.
     */
    function reloadMessageList() {
      MailGrabberDOM.deleteContent();
      getMessageList();
    }

    /**
     * Request function to get data from the server.
     *
     * @param {String} method - the request method e.g. GET, POST, DELETE
     * @param {String} path - the path which we can get/send data
     * @param {Function} fn - the function which handle the response
     */
    function request(method, path, fn) {
      var xhr = new XMLHttpRequest();

      xhr.onload = function() {
        if(xhr.status === 200) {
          fn(xhr.responseText);
        } else {
          console.log('MailGrabberRequestError:', xhr.status, xhr.statusText);
        }
      };
      xhr.open(method, MailGrabberDOM.rootPath() + path, true);
      xhr.send();
    }

    return {
      deleteMessage: deleteMessage,
      getMessage: getMessage,
      init: init
    }
  }
)();
