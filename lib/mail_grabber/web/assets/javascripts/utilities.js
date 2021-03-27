var MailGrabberUtilities = (function() {
  /**
   * Format the given date or time.
   *
   * @param {DateTime} dateTime - the message created at attribute
   * @param {String} ouputType - what type we would like to see
   *
   * @return {String} the new format of the date or time
   */
  function formatDateTime(dateTime, outputType) {
    dateTime = new Date(dateTime);
    var dateTimeNow = new Date();
    // Sun Feb 21 2021 21:00:00 GMT+0100 (Central European Standard Time)
    //  0   1  2   3      4        5         6       7        8      9
    var dateTimeComponents = dateTime.toString().split(' ');
    var output;

    switch(outputType) {
      case 'messageListDateOrTime':
        if(dateTime.getDate() === dateTimeNow.getDate()) {
          output = formatTime(dateTimeComponents[4]);
        } else if(dateTime.getFullYear() === dateTimeNow.getFullYear()) {
          output = dateTimeComponents[1] + ' ' + dateTimeComponents[2];
        } else {
          output = dateTimeComponents[3] + ' ' + dateTimeComponents[1] + ' ' +
            dateTimeComponents[2];
        }

        break;
      default:
        output = dateTimeComponents[3] + ' ' + dateTimeComponents[1] + ' ' +
          dateTimeComponents[2] + ' - ' + formatTime(dateTimeComponents[4]);
    }

    return output;
  }

  /**
   * Format the given number (attachment size).
   *
   * @param {Number} size - the size of the attachment in bytes
   *
   * @return {String} the formatted number with unit
   */
  function formatSize(size) {
    var exponent = (Math.log(size) / Math.log(1024)) | 0;
    var number = +(size / Math.pow(1024, exponent)).toFixed(1);

    return number + ' ' + ('KMGTPEZY'[exponent - 1] || '') + 'B';
  }

  /**
   * Format the given time.
   *
   * @param {String} time
   *
   * @return {String} the new format of the time
   */
  function formatTime(time) {
    var timeComponents = time.split(':');

    return timeComponents[0] + ':' + timeComponents[1];
  }

  return {
    formatDateTime: formatDateTime,
    formatSize: formatSize
  }
})();
