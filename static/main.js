$(document).ready(function() {
    $("#set-alert").on('click', function() {
        var gct = $('#gct').val();
        var message = $('#message').val() || '(no message)';
        $.get('/time/' + encodeURIComponent(gct), function(data) {
            var in_secs = data.alert_time*1000-Date.now();
            if (in_secs <= 0) {
                fail_msg("Cannot set time in the past: " + data.old_earth);
                return;
            }
            setTimeout(function() {
                  Push.create('Reminder!', {
                      body: 'You set an alert for ' + gct + '. That is NOW: ' + message,
                      link: '/#',
                      timeout: 10000,
                      vibrate: [200, 100, 200, 100, 200, 100, 200]
                  });
                }, in_secs);

            var when = new Date;
            when.setTime(data.alert_time*1000);
            succ_msg("Scheduled an alert for "+ when.toLocaleString() + ': ' + message);
        }).fail(function() {
           fail_msg("Failed to process GCT time. Did you use right format?");
        });
    });

    $("#convert").on('click', function() {
        var gct = $('#gct2').val();
        $.get('/time/' + encodeURIComponent(gct), function(data) {
            $('#conversion-result').html(
                'The Old Earth equivalent is ' + data.old_earth
                + '<br>' + data.when);
        }).fail(function() {
           $('#conversion-result').text(
               "Failed to process GCT time. Did you use right format?");
        });
    });
});

function fail_msg(err) {
    $("<p class='error'></p>").text(err).appendTo($('#messages'));
}
function succ_msg(succ) {
    $("<p class='success'></p>").text(succ).appendTo($('#messages'));
}

function formatDate(date) {
  var monthNames = [
    "January", "February", "March",
    "April", "May", "June", "July",
    "August", "September", "October",
    "November", "December"
  ];

  var day = date.getDate();
  var monthIndex = date.getMonth();
  var year = date.getFullYear();

  return day + ' ' + monthNames[monthIndex] + ' ' + year;
}
