%%%------------------------------------------
%%% head info
%%%------------------------------------------
-module(cs_channel).
-behaviour(gen_server).

%% API
-export([start_link/3,create/1]).

%%gen_server callbacks
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2,code_change/3]).

-define (SERVER, ?MODULE).
-record (state,{name,description,owner}).

%%%==========================================
%%% API
%%%==========================================
start_link(Name,Description,Owner) ->
	cs_test:print("cs_channel.erl start_link"),
	gen_server:start_link(?MODULE,[Name,Description,Owner],[]).

create([Name,Description,Owner]) ->
	cs_test:print("cs_channel.erl create"),
	cs_channel_sup:start_child([Name,Description,Owner]).
%%%==========================================
%%% gen_server callbacks
%%%==========================================
init([Name,Description,Oid]) ->
	cs_test:print("cs_channel.erl init"),
	{ok,
	#state{name = Name,description = Description,owner = Oid}
	}.

handle_call(_,_From,State) ->
	cs_test:print("cs_channel.erl handle_call"),
	ok.

handle_cast({_,Value},State) ->
	cs_test:print("cs_channel.erl handle_cast"),
	ok.

handle_info(_,State) ->
	cs_test:print("cs_channel.erl handle_info"),
	ok.

terminate(_Reason,_State) ->
	cs_test:print("cs_channel.erl terminate"),
	ok.

code_change(_OldVsn,State,_Extra) ->
	cs_test:print("cs_channel.erl code_change"),
	{ok,State}.

%%%==========================================
%%% Internal functions
%%%==========================================