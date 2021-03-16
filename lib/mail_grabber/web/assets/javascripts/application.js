(function() {
  var MailGrabber = {
    /**
     * Change which content (message part) should show. When the page is loading
     * the HTML content will be active and the others will be hidden. When we
     * click on tab e.g. Plain Text then this content will active and other
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
     * Show default backgroud image instead of any content.
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
     * set default backgroud and the infinite scroll params when we click on
     * the Reload or Delete tabs.
     */
    deleteContent: function() {
      MailGrabber.lastMessageId = -1;
      MailGrabber.page = 1;
      MailGrabber.defaultBackground();

      document
        .querySelector('ul[data-content-type=message-list]')
        .innerHTML = '';
    },

    /**
     * Delete a message when we click on the Delete tab. It will remove all
     * content and reload the message list.
     *
     * @param {Number} messageId - which message we would like to delete
     */
    deleteMessage: function(messageId) {
      MailGrabber.request('DELETE', '/message/' + messageId + '.json',
        function() {
          MailGrabber.deleteContent();
          MailGrabber.getMessageList();
        }
      );
    },

    /**
     * Delete message list when we click on the Clear tab. It will remove
     * everything.
     */
    deleteMessageList: function() {
      MailGrabber.request('DELETE', '/messages.json', function() {
        MailGrabber.deleteContent();
      });
    },

    /**
     * Get a message and render the message content, when we click on an item
     * from the message list.
     *
     * @param {Number} messageId - which message we would like to see
     */
    getMessage: function(messageId) {
      MailGrabber.request('GET', '/message/' + messageId + '.json',
        function(response) {
          MailGrabber.renderMessageContent(JSON.parse(response));
        }
      );
    },

    /**
     * Get a list of the messages. Also change the params of the infinite scroll
     * that we can know which page we are on. It checks the message ids to not
     * load those messages which are already on the list.
     */
    getMessageList: function() {
      var messageIds;

      MailGrabber.request('GET', '/messages.json?page=' + MailGrabber.page +
        '&per_page=' + MailGrabber.perPage,
        function(response) {
          response = JSON.parse(response);
          messageIds = response.map(function(hash) { return hash['id'] });

          if(response.length > 0) {
            if(messageIds.indexOf(MailGrabber.lastMessageId) === -1) {
              MailGrabber.lastMessageId = messageIds.pop();
              MailGrabber.page++;
              MailGrabber.renderMessageList(response);
            } else {
              MailGrabber.reloadMessageList();
            }
          }
        }
      );
    },

    /**
     * Scrolling infinitely. Count the height of the list and if we reached the
     * bottom of the list then tries to load more message.
     *
     * @param {Object} messageList - the message list container
     */
    infiniteScroll: function(messageList) {
      var scrollHeight = messageList.scrollHeight;
      var scrollTop = messageList.scrollTop;
      var clientHeight = messageList.clientHeight;

      if(scrollHeight - scrollTop === clientHeight) {
        MailGrabber.getMessageList();
      }
    },

    /**
     * Initialize MailGrabber. Add some event listeners to the Reload and the
     * Clear tabs then load messages and the default background.
     */
    init: function() {
      document
        .querySelector('li[data-content-type=message-reload-tab]')
        .addEventListener('click', MailGrabber.reloadMessageList);

      document
        .querySelector('li[data-content-type=message-clear-tab]')
        .addEventListener('click', MailGrabber.deleteMessageList);

      MailGrabber.loadMessageList();
      MailGrabber.defaultBackground();
    },

    /**
     * Format the given date or time.
     *
     * @param {DateTime} dateTime - the message created at attribute
     * @param {String} ouputType - what type we would like to see
     *
     * @return {String} the new format of the date or time
     */
    formatDateTime: function(dateTime, outputType) {
      dateTime = new Date(dateTime);
      var dateTimeNow = new Date();
      // Sun Feb 21 2021 21:00:00 GMT+0100 (Central European Standard Time)
      //  0   1  2   3      4        5         6       7        8      9
      var dateTimeComponents = dateTime.toString().split(' ');
      var output;

      switch(outputType) {
        case 'messageListDateOrTime':
          if(dateTime.getDate() === dateTimeNow.getDate()) {
            output = MailGrabber.formatTime(dateTimeComponents[4]);
          } else if(dateTime.getFullYear() === dateTimeNow.getFullYear()) {
            output = dateTimeComponents[1] + ' ' + dateTimeComponents[2];
          } else {
            output = dateTimeComponents[3] + ' ' + dateTimeComponents[1] + ' ' +
              dateTimeComponents[2];
          }

          break;
        default:
          output = dateTimeComponents[3] + ' ' + dateTimeComponents[1] + ' ' +
            dateTimeComponents[2] + ' - ' +
            MailGrabber.formatTime(dateTimeComponents[4]);
      }

      return output;
    },

    /**
     * Format the given number (attachment size).
     *
     * @param {Number} size - the size of the attachment in bytes
     *
     * @return {String} the formatted number with unit
     */
    formatSize: function(size) {
      var exponent = (Math.log(size) / Math.log(1024)) | 0;
      var number = +(size / Math.pow(1024, exponent)).toFixed(1);

      return number + ' ' + ('KMGTPEZY'[exponent - 1] || '') + 'B';
    },

    /**
     * Format the given time.
     *
     * @param {String} time
     *
     * @return {String} the new format of the time
     */
    formatTime: function(time) {
      var timeComponents = time.split(':');

      return timeComponents[0] + ':' + timeComponents[1];
    },

    /**
     * The last message id what loaded. If it is -1 then we have no any
     * messages.
     */
    lastMessageId: -1,

    /**
     * Load the message list. Also add event listener for infinite scroll.
     */
    loadMessageList: function() {
      var messageList =
        document
          .querySelector('ul[data-content-type=message-list]');

      messageList.addEventListener('scroll', function() {
        MailGrabber.infiniteScroll(messageList);
      });

      MailGrabber.getMessageList();
    },

    /**
     * Params that we can follow how many messages we have on the list. We are
     * loading 15 messages in every requests.
     */
    page: 1,
    perPage: 15,

    /**
     * Reload the message list. When we have new messages in the database, but
     * we scrolled down or clicked on the Reload tab.
     */
    reloadMessageList: function() {
      MailGrabber.deleteContent();
      MailGrabber.getMessageList();
    },

    /**
     * Render message attachment. Show the list of attachments at the top of the
     * message content.
     *
     * @param {Object} messageAttachments - the message attachments container
     * @param {Object} messagePart - a message part which we loaded
     */
    renderMessageAttachment: function(messageAttachments, messagePart) {
      var messageAttachment = document.createElement('a');
      var fileSize = document.createElement('span');
      var messageAttachmentTemplate =
        document
          .querySelector(
            'template[data-content-type=message-attachment-template]'
          )
          .content
          .cloneNode(true);

      messageAttachment.href =
        'data:' + messagePart.mime_type + ';base64,' + messagePart.body;
      messageAttachment.download = messagePart.filename;
      messageAttachment.innerHTML = messagePart.filename;
      messageAttachment.classList.add('color-black', 'no-text-decoration');

      fileSize.innerHTML = MailGrabber.formatSize(messagePart.size);
      fileSize.classList.add('color-gray', 'font-size-0_9', 'padding-left-10');

      [messageAttachment, fileSize].forEach(function(node) {
        messageAttachmentTemplate
          .querySelector('li[data-content-type=message-attachment]')
          .appendChild(node);
      });

      messageAttachments.classList.remove('hide');
      messageAttachments.appendChild(messageAttachmentTemplate);
    },

    /**
     * Render the HTML part of the message. If the message has inline images
     * then it will render those images as well. An iframe will contain this
     * content.
     *
     * @param {Object} iFrame - the iframe HTML tag
     * @param {Object} messageParts - the parts of the message
     * @param {Object} messageHtmlPart - the HTML part of the message
     */
    renderMessageHtmlPart: function(iFrame, messageParts, messageHtmlPart) {
      var messageInlineAttachmentRegExp = new RegExp("cid:");

      if(messageInlineAttachmentRegExp.test(messageHtmlPart)) {
        messageHtmlPart =
          MailGrabber.renderMessageInlineAttachments(
            messageParts, messageHtmlPart
          );
      }

      iFrame.srcdoc = messageHtmlPart;
      iFrame.onload = function() {
        iFrame.height = iFrame.contentDocument.body.scrollHeight + 65;
      }
    },

    /**
     * Render inline images of the message. Change the cid:something12345 with
     * the encoded image content.
     *
     * @param {Object} messageParts - the parts of the message
     * @param {Object} messageHtmlPart - the HTML part of the message
     *
     * @return {Object} messageHtmlPart - the modified HTML part of the message
     */
    renderMessageInlineAttachments: function(messageParts, messageHtmlPart) {
      messageParts.forEach(function(messagePart) {
        if(messagePart.is_attachment === 1 && messagePart.is_inline === 1) {
          messageHtmlPart = messageHtmlPart.replace('cid:' + messagePart.cid,
            'data:' + messagePart.mime_type + ';base64,' + messagePart.body);
        }
      });

      return messageHtmlPart;
    },

    /**
     * Render the content of the message (all parts, inline attachments and
     * attachments). Also it sets up event listeners of the HTML, PlainText,
     * Raw, Delete and Close tabs.
     *
     * @param {Object} response - the response the get message request
     */
    renderMessageContent: function(response) {
      var message = response.message;
      var messageParts = response.message_parts;
      var messageContentTemplate =
        document
          .querySelector('template[data-content-type=message-content-template]')
          .content
          .cloneNode(true);

      var messageContent =
        document
          .querySelector('div[data-content-type=message-content]');

      messageContent.removeAttribute('style');
      messageContent.innerHTML = '';

      messageContentTemplate
        .querySelector('div[data-content-type=message-subject]')
        .innerHTML = message.subject;

      messageContentTemplate
        .querySelector('dl[data-content-type=metadata]')
        .innerHTML = MailGrabber.renderMetadata(message);

      messageContentTemplate
        .querySelector('time[data-content-type=message-sent-at]')
        .innerHTML = MailGrabber.formatDateTime(message.created_at);

      messageContentTemplate
        .querySelectorAll('[data-message-tab]')
        .forEach(function(tab) {
          tab.addEventListener('click', MailGrabber.changeMessageContent);
        });

      messageContentTemplate
        .querySelector('li[data-content-type=message-delete-tab]')
        .addEventListener('click', function() {
          MailGrabber.deleteMessage(message.id);
        });

      messageContentTemplate
        .querySelector('li[data-content-type=message-close-tab]')
        .addEventListener('click', MailGrabber.defaultBackground);

      messageParts.forEach(function(messagePart) {
        if(messagePart.is_attachment === 0 && messagePart.is_inline === 0) {
          switch(messagePart.mime_type) {
            case 'text/html':
              MailGrabber.renderMessageHtmlPart(
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
          MailGrabber.renderMessageAttachment(
            messageContentTemplate
              .querySelector('ul[data-content-type=message-attachments]'),
            messagePart
          );
        }
      });

      messageContentTemplate
        .querySelector('pre[data-content-type=message-raw-body]')
        .innerText = message.raw;

      messageContent.appendChild(messageContentTemplate);
    },

    /**
     * Render the list of the messages. Also add event listener when click on a
     * message then it will load that conent.
     *
     * @param {Object} messages - the list of the given message.
     */
    renderMessageList: function(messages) {
      var messageListTemplate;

      var messageList =
        document
          .querySelector('ul[data-content-type=message-list]');

      messages.forEach(function(message) {
        messageListTemplate =
          document
            .querySelector('template[data-content-type=message-list-template]')
            .content
            .cloneNode(true);

        messageListTemplate
          .querySelector('li')
          .addEventListener('click', function() {
            MailGrabber.getMessage(message.id);
          });

        messageListTemplate
          .querySelector('div[data-content-type=message-senders]')
          .innerHTML = message.senders;

        messageListTemplate
          .querySelector('time[data-content-type=message-sent-at]')
          .innerHTML =
            MailGrabber
              .formatDateTime(message.created_at, 'messageListDateOrTime');

        messageListTemplate
          .querySelector('div[data-content-type=message-subject]')
          .innerHTML = message.subject;

        messageList.appendChild(messageListTemplate);
      });
    },

    /**
     * Render senders and recipients data of the message.
     *
     * @param {Object} message - the requested message
     *
     * @return {Object} the rendered metadata
     */
    renderMetadata: function(message) {
      var metadata =
        '<dt>From:</dt><dd>' + message.senders + '</dd>' +
        '<dt>To:</dt><dd>' + message.recipients + '</dd>';

      if(message.carbon_copy) {
        metadata += '<dt>Cc:</dt><dd>' + message.carbon_copy + '</dd>';
      }

      if(message.blind_carbon_copy) {
        metadata += '<dt>Bcc:</dt><dd>' + message.blind_carbon_copy + '</dd>';
      }

      return metadata;
    },

    /**
     * Request function to get data from the server.
     *
     * @param {String} method - the request method e.g. GET, POST, DELETE
     * @param {String} path - the path which we can get/send data
     * @param {Function} fn - the function which handle the response
     */
    request: function(method, path, fn) {
      var xhr = new XMLHttpRequest();

      xhr.onload = function() {
        if(xhr.status === 200) {
          fn(xhr.responseText);
        } else {
          console.log('MailGrabberRequestError:', xhr.status, xhr.statusText);
        }
      };
      xhr.open(method, MailGrabber.rootPath() + path, true);
      xhr.send();
    },

    /**
     * Root path which returns back with the server's root path. It can be empty
     * string or a string. It depends on how the server is running (standalone
     * or in Ruby on Rails).
     */
    rootPath: function() {
      return document.querySelector('body').dataset.rootPath;
    }
  };

  /**
   * When DOM loaded then call MailGrabber's init function.
   */
  document.addEventListener('DOMContentLoaded', MailGrabber.init);
}).call(this);
