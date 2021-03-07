(function() {
  var MailGrabber = {
    changeMessageContent: function(event) {
      var messageTabs =
        document
          .querySelectorAll('[data-message-tab]');

      var messageContents =
        document
          .querySelectorAll('[data-message-content]');

      var messageAttachments =
        document
          .querySelector('ul[data-content-type=message-attachments]');

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

      if(clickedTabType === 'raw') {
        messageAttachments.classList.add('hide')
      } else {
        messageAttachments.classList.remove('hide');
      }
    },

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

    deleteContent: function() {
      MailGrabber.lastMessageId = -1;
      MailGrabber.page = 1;
      MailGrabber.defaultBackground();

      document
        .querySelector('ul[data-content-type=message-list]')
        .innerHTML = '';
    },

    deleteMessage: function(messageId) {
      MailGrabber.request('DELETE', '/message/' + messageId + '.json',
        function() {
          MailGrabber.deleteContent();
          MailGrabber.getMessageList();
        }
      );
    },

    deleteMessageList: function() {
      MailGrabber.request('DELETE', '/messages.json', function() {
        MailGrabber.deleteContent();
      });
    },

    getMessage: function(messageId) {
      MailGrabber.request('GET', '/message/' + messageId + '.json',
        function(response) {
          MailGrabber.renderMessageContent(JSON.parse(response));
        }
      );
    },

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

    infiniteScroll: function(messageList) {
      var scrollHeight = messageList.scrollHeight;
      var scrollTop = messageList.scrollTop;
      var clientHeight = messageList.clientHeight;

      if(scrollHeight - scrollTop === clientHeight) {
        MailGrabber.getMessageList();
      }
    },

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

    formatTime: function(time) {
      var timeComponents = time.split(':');

      return timeComponents[0] + ':' + timeComponents[1];
    },

    lastMessageId: -1,

    loadMessageList: function() {
      var messageList =
        document
          .querySelector('ul[data-content-type=message-list]');

      messageList.addEventListener('scroll', function() {
        MailGrabber.infiniteScroll(messageList);
      });

      MailGrabber.getMessageList();
    },

    page: 1,
    perPage: 15,

    reloadMessageList: function() {
      MailGrabber.deleteContent();
      MailGrabber.getMessageList();
    },

    renderMessageAttachment: function(messagePart) {
      var messageAttachment = document.createElement('a');
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

      messageAttachmentTemplate
        .querySelector('li[data-content-type=message-attachment]')
        .appendChild(messageAttachment);

      return messageAttachmentTemplate;
    },

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

    renderMessageInlineAttachments: function(messageParts, messageHtmlPart) {
      messageParts.forEach(function(messagePart) {
        if(messagePart.is_attachment === 1 && messagePart.is_inline === 1) {
          messageHtmlPart = messageHtmlPart.replace('cid:' + messagePart.cid,
            'data:' + messagePart.mime_type + ';base64,' + messagePart.body);
        }
      });

      return messageHtmlPart;
    },

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
                atob(messagePart.body)
              );

              break;
            case 'text/plain':
              messageContentTemplate
                .querySelector('pre[data-content-type=message-text-body]')
                .innerText = atob(messagePart.body);

              break;
          }
        } else if(messagePart.is_attachment === 1 &&
                  messagePart.is_inline === 0) {
          messageContentTemplate
            .querySelector('ul[data-content-type=message-attachments]')
            .appendChild(MailGrabber.renderMessageAttachment(messagePart));
        }
      });

      messageContentTemplate
        .querySelector('pre[data-content-type=message-raw-body]')
        .innerText = message.raw;

      messageContent.appendChild(messageContentTemplate);
    },

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

    renderMetadata: function(message) {
      var metadata =
        '<dt>From:</dt><dd>' + message.senders + '</dd>' +
        '<dt>To:</dt><dd>' + message.recipients + '</dd>';

      if(message.carbon_copy) {
        metadata + '<dt>Cc:</dt><dd>' + message.carbon_copy + '</dd>';
      }

      if(message.blind_carbon_copy) {
        metadata + '<dt>Bcc:</dt><dd>' + message.blind_carbon_copy + '</dd>';
      }

      return metadata;
    },

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

    rootPath: function() {
      return document.querySelector('body').dataset.rootPath;
    }
  };

  document.addEventListener('DOMContentLoaded', MailGrabber.init);
}).call(this);
