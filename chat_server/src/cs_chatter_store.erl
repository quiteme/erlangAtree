-module(cs_chatter_store).
-export([init/0,insert/2,lookup/1,delete/1]).
-define(TABLE_ID,?MODULE).

init() ->
	cs_test:print("cs_chatter_store.erl init"),
	ets:new(?TABLE_ID,[public,named_table]),
	ok.

insert(Key,Pid) ->
	cs_test:print("cs_chatter_store.erl insert"),
	ets:insert(?TABLE_ID,{Key,Pid}).

lookup(Key) ->
	cs_test:print("cs_chatter_store.erl lookup"),
	case ets:lookup(?TABLE_ID,Key) of
		[{Key,Pid}] -> {ok,Pid};
		[] -> {error,not_found}
	end.

delete(Key) ->
	cs_test:print("cs_chatter_store.erl delete"),
	ets:delete(?TABLE_ID,Key).