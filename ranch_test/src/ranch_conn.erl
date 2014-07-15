-module(ranch_conn).

-behaviour(gen_server).
-behaviour(ranch_protocol).

%% API
-export([start_link/4]).

%%gen_server callbacks
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2,code_change/3]).
-record(protocol, {ref, socket, transport}).
%%%==========================================
%%% API
%%%==========================================
start_link(Ref, Socket, Transport, Opts) ->
	gen_server:start_link(?MODULE,[Ref, Socket, Transport],Opts).

send_data(Data) ->
	{ok,Pid} = global_properties:get_prop(connection),
	gen_server:cast(Pid, {send_data, Data}).

%%%==========================================
%%% gen_server callbacks
%%%==========================================
init([Ref, Socket, Transport]) ->
	{ok,#protocol{ref = Ref,socket = Socket,transport = Transport},0}. %设置超时时间为0
																	   %并在timeout中调用ranch:accept_ack
handle_call(_,_From,State) ->
	{noreply,State}.

handle_cast({send_data,Data},State = #protocol{transport = Transport,socket = Socket}) ->
	Transport:send(Socket, Data),
	error_logger:info_msg("tcp_normal_recv:~p",[Data]),
	{noreply,State};
handle_cast(delete,State) ->
	{stop,normal,State}.

handle_info(timeout, State=#protocol{transport = Transport, socket = Socket}) ->
    ok = ranch:accept_ack(State#protocol.ref),
    ok = Transport:setopts(Socket, [{active, once}, {packet, 2}]),
    global_properties:set_prop(connection,self()),   %此处并非是一个太好的选择，因为ranch_conn可能会起多个
    {noreply, State};
handle_info({tcp, Socket, CipherData}, State=#protocol{transport = Transport}) ->
	ok = Transport:setopts(Socket, [{active, once}]),
	error_logger:info_msg("tcp_normal_recv:~p",[CipherData]),
	send_data(CipherData),
	{noreply, State};
handle_info({tcp_closed, _Socket}, State) ->
	error_logger:info_msg("tcp_closed_recv:"),
	{stop, normal, State};
handle_info({tcp_error, _Socket, _Msg}, State) ->
	error_logger:info_msg("tcp_error_recv:"),
	{stop, normal, State};
handle_info(_,State) ->
	{ok,State}.

terminate(_Reason,_State) ->
	ok.

code_change(_OldVsn,State,_Extra) ->
	{ok,State}.

%%%==========================================
%%% Internal functions
%%%==========================================