var actions = {};

actions['index'] = function() {
    console.log('index');
}

actions['room'] = function() {
    var token = $('meta[name="token"]').attr('content');
    var uri   = "<%= @websocket_uri %>/?token=" + token;
    var ws    = new WebSocket(uri);

    ws.onopen = function(event) {
        console.log('opening');
    }

    ws.onmessage = function(event) {
        var msg = JSON.parse(event.data);
        console.log(msg);

        var f = $('#chat-text');
        var text = "";
        var time = new Date(msg.created_at);
        var timeStr = time.toLocaleTimeString();

        switch(msg.type) {
            case "user_message":
                text = "(" + timeStr + ") <b>" + msg.user_id + " (private)</b>: " + msg.body + "<br>";
                break;
            case "room_message":
                text = "(" + timeStr + ") <b>" + msg.user_id + "</b>: " + msg.body + "<br>";

                break;
            case "user_list":
                var ul = "";
                for (i=0; i < msg.user_ids.length; i++) {
                    ul += msg.user_ids[i] + "<br>";
                }
                document.getElementById("userlistbox").innerHTML = ul;
                break;
        }

        if (text.length) {
            f.append("<div class='panel panel-default'><div class='panel-heading'>" + msg.user_id + "</div><div class='panel-body'>" + text + "</div></div>");
            f.stop().animate({
                scrollTop: f[0].scrollHeight
            }, 800);
        }
    };

    ws.onclose = function(event) {
    };

    ws.onerror = function(event) {
        console.log('error', event);
    };

    $("#input-form").on("submit", function(event) {
        event.preventDefault();
        var body = $("#input-text")[0].value;
        ws.send(JSON.stringify({ type: "room_message", body: body }));
        $("#input-text")[0].value = "";
    });
}

$(document).ready(function() {
    var actionName = $('body').data('action');
    if (actions[actionName]) {
        actions[actionName]();
    }
});
