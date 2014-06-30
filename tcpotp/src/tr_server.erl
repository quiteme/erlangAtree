%%%------------------------------------------
%%% head info
%%%------------------------------------------

-module(tr_server).
-behaviour(gen_server).

%% API
-export([start_link/1,start_link/0,get_count/0,get_count/1,stop/0]).

%%gen_server callbacks
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2,code_change/3]).

-define (SERVER, ?MODULE).
-define (DEFAULT_PORT,1055).

-record (state,{port,lsock,request_count = 0}).

%%%==========================================
%%% API
%%%==========================================

%%-------------------------------------------
%% @spec start_link(Port::integer()) -> {OK,Pid}
%% where
%%    Pid = pid()
%% @end
%%-------------------------------------------
start_link(Port) ->
	print("start_link been call"),
	gen_server:start_link({local,?SERVER},?MODULE,[Port],[]).

start_link() ->
	start_link(?DEFAULT_PORT).

%%-------------------------------------------
%% @spec get_count() -> {OK,Count}
%% where
%%    Count = integer()
%% @end
%%-------------------------------------------
get_count() ->
	print("get_count been call"),
	gen_server:call(?SERVER,get_count).

get_count(Pid) ->
	gen_server:call(Pid,get_count).

%%-------------------------------------------
%% @spec stop() -> ok
%% @end
%%-------------------------------------------
stop() ->
	print("stop been call"),
	gen_server:cast(?SERVER,stop).

%%%==========================================
%%% gen_server callbacks
%%%==========================================
init([Port]) ->
	print("init been call back"),
	{ok,LSock} = gen_tcp:listen(Port,[{active,true}]),
	{ok,#state{port = Port,lsock = LSock},0}.

handle_call(get_count,_From,State) ->
	print("handle_call been call back"),
	{reply,{ok,State#state.request_count},State}.

handle_cast(stop,State) ->
	print("handle_cast been call back"),
	{stop,normal,State}.

handle_info({tcp,Socket,RawData},State) ->
	print("handle_info been call back 1"),
	do_rpc(Socket,RawData),
	RequestCount = State#state.request_count,
	{noreply,State#state{request_count = RequestCount + 1}};
handle_info(timeout,#state{lsock = LSock} = State) ->
	print("handle_info been call back 2"),
	{ok,_Sock} = gen_tcp:accept(LSock),
	{noreply,State}.

terminate(_Reason,_State) ->
	%print("terminate been call back"),  %此处不能打调试信息
	ok.

code_change(_OldVsn,State,_Extra) ->
	print("code_change been call back"),
	{ok,State}.

%%%==========================================
%%% Internal functions
%%%==========================================
do_rpc(Socket,RawData) ->
	try
		{M,F,A} = split_out_mfa(RawData),
		Result = apply(M,F,A),
		print("do_rpc,normal"),
		gen_tcp:send(Socket,io_lib:fwrite("~p~n",[Result]))
	catch
		_Class:Err ->
			print("do_rpc,err"),
			gen_tcp:send(Socket,io_lib:fwrite("~p~n",[Err]))
	end.

split_out_mfa(RawData) ->
	MFA = re:replace(RawData,"\r\n$","",[{return,list}]),
	{match,[M,F,A]} = re:run(MFA,"(.*):(.*)\s*\\((.*)\s*\\)\s*.\s*$",[{capture,[1,2,3],list},ungreedy]),
	{list_to_atom(M),list_to_atom(F),args_to_atom(A)}.

args_to_atom(RawArgs) ->
	{ok,Toks,_Line} = erl_scan:string("[" ++ RawArgs ++ "].",1),
	{ok,Args} = erl_parse:parse_term(Toks),
	Args.

print(Log) ->
	io:format("~p~n",[Log]).