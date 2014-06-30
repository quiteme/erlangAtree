-module(cs_test).
-export([print/1,print_debug/1,print_info/1]).
-define(PRINT,0).

-include_lib("eunit/include/eunit.hrl").

print(Value) ->
	if
		?PRINT > 0 -> io:format("~n~p~n",[Value]);
		true -> true
	end.

print_debug(Value) ->
	if
		?PRINT > 0 -> 
			io:format("~n+++++++++++++++++++++++++++++++++++++++"),
			io:format("~n~p~n",[Value]),
			io:format("+++++++++++++++++++++++++++++++++++++++~n");
		true -> true
	end.

print_info(Value) ->
	error_logger:info_msg("LOG-INFO:~n~p~n",Value).

%% test chatter
chatter_test_() ->
	{foreach,
	fun start_chatter/0,
	fun stop_chatter/1,
	[
		fun fetch_chatter/1,
		fun cast_chatter/1
	]
	}.

start_chatter() ->
	cs_chatter:start_link().

stop_chatter({ok,Pid}) ->
	cs_chatter:stop(Pid).

fetch_chatter({ok,Pid}) ->
	[?_assertMatch({ok,_,_,_},cs_chatter:fetch(Pid)),
	 ?_assertMatch({ok,_,_,_},cs_chatter:fetch_time(Pid))].

cast_chatter({ok,Pid}) ->
	[?_assertMatch(ok,cs_chatter:replace_cast(Pid,{Pid,1})),
	 ?_assertMatch(ok,cs_chatter:replace_cast(Pid)),
	 ?_assertMatch(ok,cs_chatter:chat_cast(Pid,["a2","this is a test!"]))].

%% test channel
channel_test() ->
	{ok,Pid} = start_channel(),
	stop_channel(Pid).

start_channel() ->
	cs_channel:start_link("c1","this is a channel test",'<0,41,0>').

stop_channel(Pid) ->
	cs_channel:delete(Pid).

%% test chatter store
chatter_store_test() ->
	?assertMatch(ok,cs_chatter_store:init()),
	?assertMatch(true,cs_chatter_store:insert("a1",'<0,39,0>')),
	?assertMatch(true,cs_chatter_store:insert("a2",'<0,40,0>')),
	?assertMatch({ok,_},cs_chatter_store:lookup("a1")),
	?assertMatch(true,cs_chatter_store:delete("a1")).

%% test channel store
channel_store_test() ->
	Cid = '<0,40,0>',
	Pid = '<0,39,0>',
	?assertMatch(ok,cs_channel_store:init()),
	?assertMatch(true,cs_channel_store:insert(Cid,[{cid,Cid},{manager,[Pid]},{chatter,[]},{count,1}])),
	?assertMatch(true,cs_channel_store:insert(Cid,[{cid,Cid},{manager,[Pid]},{chatter,[Pid]},{count,2}])),
	?assertMatch(true,cs_channel_store:insert(Pid,[{cid,Pid},{manager,[Cid]},{chatter,[]},{count,1}])),
	?assertMatch({ok,_},cs_channel_store:lookup(Cid)),
	?assertMatch(true,cs_channel_store:delete(Cid)).