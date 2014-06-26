-module(chat_server).
-export([insert_chatter/1,create_channel/3,join_channel/2,chat_to_chatter/3,chat_to_channel/2]).
-define(MAX_CHANNEL,100).
-define(CHAT_DELAY,1).

insert_chatter(Key) ->
	cs_test:print("chat_server.erl insert_chatter"),
	case cs_chatter_store:lookup(Key) of
		{error,_} ->
			{ok,Pid} = cs_chatter:create(),
			cs_chatter_store:insert(Key,Pid);
		{ok,_} -> {error,had_bang}
	end.

create_channel(Key,Name,Description) ->
	cs_test:print("chat_server.erl create_channel"),
	case cs_chatter_store:lookup(Key) of 									%1.find chatter
		{ok,Pid} ->
			Filters = [{fun chatter_can_create_channel/1,[Pid]},{fun chatter_create_channel/1,[{Name,Description,Pid}]}],
			case run_filters_return(Filters) of %2.can create channel? %3.create channel 1->manager
				[ok,{ok,Cid},ok] -> cs_chatter:replace_cast(Pid,{Cid,1}); %4.update chatter state
				{error,Value} -> {error,Value}
			end;
		{error,_} -> {error,not_fount}
	end.

join_channel(Key,Joinkey) ->
	Filters = [{fun chatter_can_join_channel/1,[Key]},{fun chatter_can_be_join/1,[Joinkey]}],
	case run_filters_return(Filters) of
		[{ok,Pid},{ok,Cid},ok] ->
			case chatter_join_channel(Pid,Cid) of
				{ok,_} -> cs_chatter:replace_cast(Pid,{Cid,2});    % create channel 2->normal chatter
				{error,Value} -> {error,Value}
			end;
		{error,Value} -> {error,Value} 
	end.

chat_to_chatter(From,To,Context) ->
	Filters = [{fun cs_chatter_store:lookup/1,[From]},{fun cs_chatter_store:lookup/1,[To]}],
	case run_filters_return(Filters) of 
		[{ok,Fid},{ok,Tid},ok] ->
			Filters1 = [{fun cs_chatter:fetch/1,[Fid]},{fun cs_chatter:fetch/1,[Tid]}],
			case run_filters_return(Filters1) of
				[{ok,Cid,_,Manager},{ok,Cid,_,_},ok] when Manager > 0 ->
					cs_chatter:chat_cast(Tid,[From,Context]),
					cs_chatter:chat_cast(Fid,[From,Context]);
				{error,Value} -> {error,Value};
				_ -> {error,not_channel}
			end;
		{error,Value} -> {error,Value}
	end.

chat_to_channel(From,Context) ->
	case cs_chatter_store:lookup(From) of
		{ok,Pid} ->
			case cs_chatter:fetch_time(Pid) of
				{ok,Cid,Delay,Manager} when (Manager > 0  andalso Delay >= ?CHAT_DELAY) ->
					case cs_channel_store:lookup(Cid) of 
						{ok,[_,{manager,Mid},{chatter,Sid},_]} ->
							chatter_to_list(From,Mid,Context),
							chatter_to_list(From,Sid,Context),
							cs_chatter:replace_cast(Pid);
						_ -> {error,not_channel} 
					end;
				_ -> {error,not_chatter} 
			end;
		{error,Value} -> {error,Value}
	end.
%%%==========================================
%%% Internal functions
%%%==========================================
chatter_can_create_channel(Pid) ->
	cs_test:print("chat_server.erl chatter_can_create_channel"),
	case cs_chatter:fetch(Pid) of
		{ok,_,_,Manager} when Manager =:= 0 -> 
			ok;
		_ -> {error,had_channel}
	end.

chatter_create_channel({Name,Description,Pid}) ->
	cs_test:print("chat_server.erl create_channel"),
	case cs_channel_store:lookup(Pid) of
		{error,_} ->
			{ok,Cid} = cs_channel:create([Name,Description,Pid]),
			cs_channel_store:insert(Cid,[{cid,Cid},{manager,[Pid]},{chatter,[]},{count,1}]),
			{ok,Cid};
		{ok,_} -> {error,had_bang}
	end.

chatter_can_join_channel(Key) ->
	cs_test:print("chat_server.erl chatter_can_join_channel"),
	case cs_chatter_store:lookup(Key) of
		{ok,Pid} -> 
			case cs_chatter:fetch(Pid) of 
				{ok,_,_,Manager} when Manager =:= 0 -> {ok,Pid};
				_ -> {error,Pid}
			end;
		{error,_} -> {error,not_found}
	end.

chatter_can_be_join(Key) ->
	cs_test:print("chat_server.erl chatter_can_be_join"),
	case cs_chatter_store:lookup(Key) of
		{ok,Pid} -> 
			case cs_chatter:fetch(Pid) of 
				{ok,Cid,_,Manager} when Manager > 0 -> {ok,Cid};
				_ -> {error,Pid}
			end;
		{error,_} -> {error,not_found}
	end.

chatter_join_channel(Pid,Cid) ->
	case cs_channel_store:lookup(Cid) of
		{ok,[{cid,Cid},{manager,Manager},{chatter,Chatter},{count,Count}]} when Count < ?MAX_CHANNEL ->
			cs_channel_store:insert(Cid,[{cid,Cid},{manager,Manager},{chatter,[Pid|Chatter]},{count,Count + 1}]),
			{ok,Cid};
		{error,_} -> {error,not_found}
	end.

chatter_to_list(From,Tids,Context) ->
	[begin 
		cs_chatter:chat_cast(Tid,[From,Context])
	end || Tid <- Tids].

%有返回的filters调用
run_filters_return([{Fun, [Args]}|Filters]) ->
	case Fun(Args) of
		{error,Msg} -> {error,Msg};
		Result -> [Result | run_filters_return(Filters)]
	end;
run_filters_return([]) -> [ok].

%不需返回的filters调用
run_filters([{Fun, Args}|Filters]) ->
	case Fun(Args) of 
		{error, Msg} -> {error, Msg};
		_ -> run_filters(Filters)
	end;
run_filters([]) -> ok.