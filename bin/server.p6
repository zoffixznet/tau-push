use Cro::HTTP::Router;
use Cro::HTTP::Server;
use HTML::Escape;
use JSON::Fast;
use Games::TauStation::DateTime;
use Number::Denominate;
my &H := &escape-html;

sub MAIN (Str:D :$host = '0.0.0.0', UInt:D :$port = 10000) {
    my $application = route {
        get -> {
            content 'text/html', html-home-page
        }
        get -> 'time', *@gct {
            my $gct = join '/', @gct; # fu apache
            say "Got time $gct";
            if (try GCT.new: $gct) -> $time {
                say "Processed time to $time.gist() [$time.posix()]";
                content 'application/json', to-json %(
                    alert_time => $time.posix,
                    old_earth  => $time.OE,
                    when       => "which is {
                      denominate ($time.Instant - now).Rat} from now"
                )
            } else { not-found }
        }
        my subset StaticContent of Str where * ∈ <
            main.css  push.min.js  main.js
        >;
        get -> StaticContent $file { static "static/$file" }
    }

    with Cro::HTTP::Server.new: :$host, :$port, :$application {
        $^server.start;
        say "Started server http://$host:$port";
        react whenever signal SIGINT {
            $server.stop;
            exit;
        }
    }
}

sub html-home-page {
    html-layout-default q:to/✎✎✎✎✎/;
    <div class="panel">
        <h2>Convert Time</h2>
        <p>Enter <a href="https://alpha.taustation.space/archive/general/gct">GCT</a> absolute time
          or relative duration. Click button. Receive Old Earth time:</p>
        <div id="messages2"></div>
        <input type="text" id="gct2" placeholder="198.17/95:875 GCT">
        <button id="convert">Convert</button>
        <div id="conversion-result"></div>
    </div>
    <div class="panel">
        <h2>Push Notification</h2>
        <p>Enter <a href="https://alpha.taustation.space/archive/general/gct">GCT</a> absolute time
          or relative duration. Click button. Receive push notification at that time</p>
        <div id="messages"></div>
        <input type="text" id="gct" placeholder="198.17/95:875 GCT">
        <button id="set-alert">Set alert</button>
    </div>
    ✎✎✎✎✎
}

sub html-layout-default (Str:D $content) {
    q:to/✎✎✎✎✎/;
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1">

      <title>Tau Station Alerts</title>
      <link rel="stylesheet" href="/main.css">
    </head>
    <body>
      <div id="content">
        \qq[$content]
      </div>
      <script src="https://code.jquery.com/jquery-latest.min.js"></script>
      <script src="/push.min.js"></script>
      <script src="/main.js"></script>
    </body>
    </html>
    ✎✎✎✎✎
}

sub linkify (Str:D $text --> Str:D) {
    $text.subst: :g, /'http' s? '://' \S+ \. \S+/, { qq{<a href="$_">$_\</a>} }
}
