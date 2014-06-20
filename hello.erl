-module (hello).
-export ([start/0]).
-export ([run/0]).

start()->
	io:format("erlang!~n"),
	spawn(io, format, ["erlang!"]). 

run()->
	Pid = spawn(fun ping/0),  %spawn的重载 调函数引用
	Pid ! self(),             %发送 (目的地 ！消息)
	receive
		pong -> ok
	end.

ping()->
	receive
		From -> From ! pong    %接收方From包含了发送方ID
	end.