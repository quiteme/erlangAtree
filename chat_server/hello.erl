-module(hello).
-export([run/0]).

run() ->
	application:start(chat_server),
	chat_server:insert_chatter("a1"),
	chat_server:create_channel("a1","c1","channel"),
	chat_server:insert_chatter("a2"),
	chat_server:insert_chatter("a3"),
	chat_server:insert_chatter("a4"),
	chat_server:insert_chatter("a5"),
	chat_server:join_channel("a2","a1"),
	chat_server:join_channel("a3","a1"),
	chat_server:join_channel("a4","a1"),
	chat_server:join_channel("a5","a1"),
	%chat_server:chat_to_chatter("a1","a2","this is a test!").
	%chat_server:chatter_to_channel("a1","this is a test!"),
	%chat_server:chatter_to_channel("a1","this is a test!").
	chat_server:leave_channel("a3"),
	chat_server:drop_channel("a1").