-module(chat_server).
-export([insert_chatter/1,create_channel/3,join_channel/2]).
-define(MAX_CHANNEL,100).

insert_chatter(Key) ->
	cs_test:print("chat_server.erl insert_chatter"),
	case cs_chatter_store:lookup(Key) of
		{error,_} ->
			{ok,Pid} = cs_chatter:create(),
			cs_chatter_store:insert(Key,Pid);
			%cs_test:print(Pid);
		{ok,_} -> {error,had_bang}
	end.

create_channel(Key,Name,Description) ->
	cs_test:print("chat_server.erl create_channel"),
	case cs_chatter_store:lookup(Key) of 									%1.find chatter
		{ok,Pid} ->
			case chatter_can_create_channel(Pid) of 						%2.can create channel?
				{ok,_} -> 
					case chatter_create_channel(Name,Description,Pid) of 	%3.create channel 1->manager
						{ok,Cid} -> cs_chatter:replace_cast(Pid,{Cid,1}); 	%4.update chatter state
			 			{error,Value} -> {error,Value}
			 		end;
			 	{error,Value} -> {error,Value}
			end;
		{error,_} -> {error,not_fount}
	end.

join_channel(Key,Joinkey) ->
	case chatter_can_join_channel(Key) of
		{ok,Pid} ->
			case chatter_can_be_join(Joinkey) of
				{ok,Jid} ->
					case chatter_join_channel(Pid,Jid) of
						{ok,Cid} -> cs_chatter:replace_cast(Pid,{Cid,2});    % create channel 2->normal chatter
						{error,Value} -> {error,Value}
					end;
				{error,Value} -> {error,Value} 
			end;
		{error,Value} -> {error,Value}
	end.
%%%==========================================
%%% Internal functions
%%%==========================================
chatter_can_create_channel(Pid) ->
	cs_test:print("chat_server.erl chatter_can_create_channel"),
	{ok,_,_,Manager} = cs_chatter:fetch(Pid),
	if
		Manager =:= 0 -> {ok,Manager};
		Manager -> {error,Manager}
	end.

chatter_create_channel(Name,Description,Pid) ->
	cs_test:print("chat_server.erl create_channel"),
	case cs_channel_store:lookup(Pid) of
		{error,_} ->
			{ok,Cid} = cs_channel:create([Name,Description,Pid]),
			cs_channel_store:insert(Pid,[{cid,Cid},{chatter,[Pid]},{count,1}]);
		{ok,_} -> {error,had_bang}
	end.

chatter_can_join_channel(Key) ->
	cs_test:print("chat_server.erl chatter_can_join_channel"),
	case cs_chatter_store:lookup(Key) of
		{ok,Pid} -> 
			{ok,_,_,Manager} = cs_chatter:fetch(Pid),
			if 
				Manager =:= 0 -> {ok,Pid};
				Manager -> {error,Pid}
			end;
		{error,_} -> {error,not_found}
	end.

chatter_can_be_join(Key) ->
	cs_test:print("chat_server.erl chatter_can_be_join"),
	case cs_chatter_store:lookup(Key) of
		{ok,Pid} -> 
			{ok,_,_,Manager} = cs_chatter:fetch(Pid),
			if 
				Manager > 0 -> {ok,Pid};
				Manager -> {error,Pid}
			end;
		{error,_} -> {error,not_found}
	end.

chatter_join_channel(Pid,Jid) ->
	case cs_channel_store:lookup(Jid) of
		{ok,Result} ->
			[{cid,Cid},{chatter,Chatter},{count,Count}] = Result,
			if
				Count < ?MAX_CHANNEL ->
					cs_channel_store:insert(Jid,[{cid,Cid},{chatter,[Pid|Chatter]},{count,Count + 1}]),
					{ok,Cid};
				Count -> {error,over_chatter}
			end;
		{error,_} -> {error,not_found}
	end.