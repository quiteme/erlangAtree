%%%------------------------------------------
%%% head info
%%%------------------------------------------
-module(cs_chatter).
-behaviour(gen_server).
%% API
-export([start_link/0,create/0,fetch/1,replace_cast/2]).
%%gen_server callbacks
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2,code_change/3]).
-define (SERVER, ?MODULE).
-record (state,{channel = 0,delay = 0,manager = 0}). 

%%%==========================================
%%% API
%%%==========================================
start_link() ->
	cs_test:print("cs_chatter.erl start_link"),
	gen_server:start_link(?MODULE,[],[]).

create() ->
	cs_test:print("cs_chatter.erl create"),
	cs_chatter_sup:start_child().

fetch(Pid) ->
	gen_server:call(Pid,fetch).

replace_cast(Pid,Value) ->
	cs_test:print("cs_chatter.erl replace_cast"),
	gen_server:cast(Pid,{replace,Value}).
%%%==========================================
%%% gen_server callbacks
%%%==========================================
init([]) ->
	cs_test:print("cs_chatter.erl init"),
	{ok,#state{}}.

handle_call(fetch,_From,State) ->
	cs_test:print("cs_chatter.erl handle_call"),
	#state{channel = Cid,delay = Delay,manager = Manager} = State,
	{reply,{ok,Cid,Delay,Manager},State}.

handle_cast({replace,{Cid,Manager}},State) ->
	cs_test:print("cs_chatter.erl handle_cast"),
	#state{} = State,
	{noreply,State#state{channel = Cid,manager = Manager}}.

handle_info(timeout,State) ->
	cs_test:print("cs_chatter.erl handle_info"),
	{stop,normal,State}.

terminate(_Reason,_State) ->
	cs_test:print("cs_chatter.erl terminate"),
	ok.

code_change(_OldVsn,State,_Extra) ->
	cs_test:print("cs_chatter.erl code_change"),
	{ok,State}.

%%%==========================================
%%% Internal functions
%%%==========================================