-module(sc_event_logger).
-behaviour(gen_event).
-export([add_hander/0,delete_handler/0]).
-export([init/1,handle_event/2,handle_call/2,handle_info/2,code_change/3,terminate/2]).

add_hander()->
	sc_event:add_hander(?MODULE,[]).

delete_handler()->
	sc_event:delete_handler(?MODULE,[]).

init([]) ->
	ok.
	
handle_event({create,{Key,Value}},State) ->
	error_logger:info_msg("create(~w,~w)~n",[Key,Value]),
	{ok,State};
handle_event({lookup,Key},State) ->
	error_logger:info_msg("lookup(~w)~n",[Key]),
	{ok,State};
handle_event({delete,Key},State) ->
	error_logger:info_msg("delete(~w)~n",[Key]),
	{ok,State};
handle_event({replace,{Key,Value}},State) ->
	error_logger:info_msg("replace(~w,~w)~n",[Key,Value]),
	{ok,State}.

handler_call(Key,Value) ->
	ok.

handle_info(Key,Value) ->
	ok.

code_change(_OldVsn,State,_Extra) ->
	ok.

terminsate(_Reason,_State) ->
	ok,