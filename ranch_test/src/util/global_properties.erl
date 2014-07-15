%%%
%%% 该功能如果使用了gproc，可以考虑用gproc实现
%%%
-module(global_properties).
-export([init/0,set_prop/2,get_prop/1,drop_prop/1]).

-define(TABLE_ID,?MODULE).

init() ->
	ets:new(?TABLE_ID,[public,named_table]),
	ok.

set_prop(Key,Prop) ->
	ets:insert(?TABLE_ID,{Key,Prop}).

get_prop(Key) ->
	case ets:lookup(?TABLE_ID,Key) of
		[{Key,Prop}] -> {ok,Prop};
		[] -> {error,not_found}
	end.

drop_prop(Key) ->
	ets:delete(?TABLE_ID,Key).