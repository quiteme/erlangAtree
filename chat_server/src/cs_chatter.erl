%%%------------------------------------------
%%% head info
%%%------------------------------------------
-module(cs_chatter).
-behaviour(gen_server).
%% API
-export([start_link/0,create/0,fetch/1,fetch_time/1,replace_cast/1,replace_cast/2,chat_cast/2,stop/1]).
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
	cs_test:print("cs_chatter.erl fetch"),
	gen_server:call(Pid,fetch).

fetch_time(Pid) ->
	cs_test:print("cs_chatter.erl fetch_time"),
	gen_server:call(Pid,fetch_time).

replace_cast(Pid,Value) ->
	cs_test:print("cs_chatter.erl replace_cast"),
	gen_server:cast(Pid,{replace,Value}).

replace_cast(Pid) ->
	gen_server:cast(Pid,{chatrep}).

chat_cast(Tid,Value) ->
	cs_test:print("cs_chatter.erl replace_cast"),
	gen_server:cast(Tid,{chatto,Value}).

stop(Pid) ->
	cs_test:print("cs_chatter.erl stop"),
	gen_server:cast(Pid,stop).

%%%==========================================
%%% gen_server callbacks
%%%==========================================
init([]) ->
	cs_test:print("cs_chatter.erl init"),
	{ok,#state{}}.

handle_call(fetch,_From,State) ->
	cs_test:print("cs_chatter.erl handle_call"),
	#state{channel = Cid,delay = Delay,manager = Manager} = State,
	{reply,{ok,Cid,Delay,Manager},State};
handle_call(fetch_time,_From,State) ->
	cs_test:print("cs_chatter.erl handle_call"),
	#state{channel = Cid,delay = Delay,manager = Manager} = State,
	Time = time_left(Delay),
	{reply,{ok,Cid,Time,Manager},State}.

handle_cast({replace,{Cid,Manager}},State) ->
	cs_test:print("cs_chatter.erl handle_cast"),
	#state{} = State,
	{noreply,State#state{channel = Cid,manager = Manager}};
handle_cast({chatto,[From,Context]},State) ->
	#state{} = State,
	cs_test:print_debug([From,Context]),
	{noreply,State};
handle_cast({chatrep},State) ->
	Now = calendar:local_time(),
	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
	#state{} = State,
	{noreply,State#state{delay = CurrentTime}};
handle_cast(stop,State) ->
	{stop,normal,State}.

handle_info(timeout,State) ->
	cs_test:print("cs_chatter.erl handle_info"),
	{stop,normal,State}.

terminate(_Reason,_State) ->
	ok.

code_change(_OldVsn,State,_Extra) ->
	cs_test:print("cs_chatter.erl code_change"),
	{ok,State}.

%%%==========================================
%%% Internal functions
%%%==========================================
time_left(Delaytime) ->
	Now = calendar:local_time(),
	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
	case CurrentTime - Delaytime of
		Time when Time =< 0 -> 0;
		Time -> Time
	end.