'use strict';

var app = angular.module('chatApp', [
  'ngResource',
  'ui.bootstrap'
]);

app.factory('User', function($resource) {
    return $resource('users/:id', { id: '@id' }, {
        query: { method:'GET', isArray: true }
    });
});

app.factory('Room', function($resource) {
    return $resource('rooms/:id', { id: '@id' }, {
        query: { method:'GET', isArray: true }
    });
});

app.factory('meta', function() {
    var metas = document.getElementsByTagName('meta'); 
    var data = {};

    for (var i = 0; i < metas.length; i++) {
        var name = metas[i].getAttribute("name");
        var content = metas[i].getAttribute("content");
        data[name] = content;
    }

    return data;
});

app.factory('WsService', function(meta) {
    var my = {},
        ws = null,
        token = null,
        websocket_uri = null,
        callbacks = {};

    my.init = function() {
        ws = new WebSocket(meta.websocket_uri + "/?token=" + meta.token);

        ws.onopen = function() {
            console.log('opened ws');
        };

        ws.onclose = function() {
            console.log('closed ws');
        };

        ws.onmessage = function(event) {
            var msg = JSON.parse(event.data);
            console.log(msg);
            if (msg.type) {
                var c = callbacks[msg.type];
                if (c && c.length) {
                    for (var i = 0; i < c.length; i++) {
                        c[i](msg);
                    }
                }
            }
        };
    }

    my.on = function(event, callback) {
        if (!callbacks[event]) {
            callbacks[event] = [];
        }

        callbacks[event].push(callback);
    }

    my.send = function(msg) {
        ws.send(JSON.stringify(msg));
    }

    return my;
});

app.controller('MessagesController', function(
    $scope,
    User,
    Room,
    WsService,
    meta
) {
    $scope.alerts = [];
    $scope.users = User.query();
    $scope.rooms = Room.query();

    WsService.init();

    $scope.currentUser = null;
    $scope.users.$promise.then(function(result) {
        for (var i = 0; i < result.length; i++) {
            if (result[i].id == meta.id) {
                $scope.currentUser = result[i];
                break;
            }
        }
    });

    $scope.currentRoom = null;
    $scope.currentConversation = null;
    $scope.currentRecipient = null;
    $scope.currentWindowName = "Welcome to Chat";

    $scope.messages = [];
    $scope.newMessage = null;

    $scope.closeAlert = function(index) {
        $scope.alerts.splice(index, 1);
    };

    $scope.newRoomName = null;
    $scope.newRoom = function() {
        var newRoom = new Room();
        newRoom.name = $scope.newRoomName;
        newRoom.$save()
            .then(function(res) {
                $scope.newRoomName = null;
                $scope.enterRoom(res.id);
                $scope.rooms.push(res);
            });
    }

    $scope.enterRoom = function(id) {
        Room.get({ id: id }, function(roomData) {
            if ($scope.currentRoom && $scope.currentRoom != roomData.room.id) {
                WsService.send({
                    type: 'room_leave',
                    room_id: $scope.currentRoom
                });
            }

            if ($scope.currentConversation) {
                WsService.send({
                    type: 'conversation_leave',
                    conversation_id: $scope.currentConversation,
                    recipient_id: $scope.currentRecipient
                });
            }

            $scope.currentRoom = roomData.room.id;
            $scope.currentConversation = null;
            $scope.currentRecipient = null;
            $scope.currentWindowName = roomData.room.name;

            $scope.messages.length = 0;
            for (var i = 0; i < roomData.room_messages.length; i++) {
                $scope.messages.push(roomData.room_messages[i]);
            }

            WsService.send({
                type: 'room_join',
                room_id: roomData.room.id
            });
        });
    }

    $scope.enterConversation = function(id) {
        User.get({ id: id }, function(convoData) {
            if ($scope.currentConversation && $scope.currentConversation != convoData.other.id) {
                WsService.send({
                    type: 'conversation_leave',
                    conversation_id: $scope.currentConversation,
                    recipient_id: $scope.currentRecipient
                });
            }

            if ($scope.currentRoom) {
                WsService.send({
                    type: 'room_leave',
                    room_id: $scope.currentRoom
                });
            }

            $scope.currentRoom = null;
            $scope.currentConversation = convoData.conversation.id;
            $scope.currentRecipient = convoData.other.id;
            $scope.currentWindowName = convoData.other.name;

            $scope.messages.length = 0;
            for (var i = 0; i < convoData.conversation_messages.length; i++) {
                $scope.messages.push(convoData.conversation_messages[i]);
            }

            WsService.send({
                type: 'conversation_join',
                conversation_id: convoData.conversation.id,
                recipient_id: convoData.other.id
            });
        });
    }

    $scope.sendMessage = function() {
        if ($scope.newMessage && $scope.newMessage.length) {
            var msg = {};
            if ($scope.currentRoom) {
                msg.type = "room_message";
                msg.room_id = $scope.currentRoom;
            } else if ($scope.currentConversation) {
                msg.type = "conversation_message";
                msg.recipient_id = $scope.currentRecipient;
                msg.conversation_id = $scope.currentConversation;
            }
            if (msg.type) {
                msg.body = $scope.newMessage;
                WsService.send(msg);
                $scope.newMessage = null;
            } else {
                $scope.alerts.push({ msg: "Please join a room." });
            }
        }
    }

    WsService.on('room_message', function(msg) {
        if ($scope.currentRoom == msg['room_id']) {
            $scope.$apply(function() {
                $scope.messages.push(msg);
            });
        }
    });

    WsService.on('conversation_message', function(msg) {
        if ($scope.currentConversation == msg['conversation_id']) {
            $scope.$apply(function() {
                $scope.messages.push(msg);
            });
        }
    });
});
