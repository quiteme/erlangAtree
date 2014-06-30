-module(cs_app_test).

-include_lib("eunit/include/eunit.hrl").
%% test application
application_test_() ->
	{setup,
	fun start/0,
	fun stop/1,
	fun func_test/1
	}.

start() ->
	application:start(chat_server).

stop(_Pid) ->
	application:stop(chat_server).

func_test(_Pid) ->
	[?_assertMatch(true,chat_server:insert_chatter("a1")),
	 ?_assertMatch(true,chat_server:insert_chatter("a2")),
	 ?_assertMatch(true,chat_server:insert_chatter("a3")),
	 ?_assertMatch(true,chat_server:insert_chatter("a4")),
	 ?_assertMatch(true,chat_server:insert_chatter("a5")),
 	 ?_assertMatch(ok,chat_server:create_channel("a1","c1","channel")),
 	 ?_assertMatch(ok,chat_server:join_channel("a2","a1")),
	 ?_assertMatch(ok,chat_server:join_channel("a3","a1")),
	 ?_assertMatch(ok,chat_server:join_channel("a4","a1")),
	 ?_assertMatch(ok,chat_server:join_channel("a5","a1")),
	 ?_assertMatch(ok,chat_server:chat_to_chatter("a1","a2","this is a test!")),
	 ?_assertMatch(ok,chat_server:chatter_to_channel("a1","this is a test!")),
	 ?_assertMatch({error,_},chat_server:chatter_to_channel("a1","this is a test!")),
	 ?_assertMatch({error,_},chat_server:leave_channel("a1")),
	 ?_assertMatch(ok,chat_server:leave_channel("a3")),
	 ?_assertMatch({error,_},chat_server:drop_channel("a2")),
	 ?_assertMatch(true,chat_server:drop_channel("a1"))].