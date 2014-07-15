-module(ranch_client).
-export([test_msg/1]).

connect() ->
	SomeHost = "localhost",
	gen_tcp:connect(SomeHost,5555,[{active,false},{packet,2}]),
	{ok,Sock} = gen_tcp:connect(SomeHost,5555,[{active,false},{packet,2}]),
	%put(sock,Sock). %此处不存入线程字典
	{ok,Sock}.

send_request(Sock,Value) ->
	gen_tcp:send(Sock,Value).

recv_response(Sock) ->
	case gen_tcp:recv(Sock,0) of
		{ok,Packet} ->
			error_logger:info_msg("Recv_normal:~p",[Packet]);
		Error ->
			error_logger:info_msg("Recv_error:~p",[Error])
	end.

test_msg(Value) ->
	{ok,Sock} = connect(),
	send_request(Sock,Value),
	Response = recv_response(Sock),
	error_logger:info_msg("Recv__normal:~p",[Response]),
	ok = gen_tcp:close(Sock).