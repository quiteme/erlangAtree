-module(hello).
-export([run/0]).

run() ->
	application:start(chat_server),
	chat_server:insert_chatter("a1"),
	chat_server:create_channel("a1","c1","channel"),
	chat_server:insert_chatter("a2"),
	chat_server:join_channel("a2","a1").