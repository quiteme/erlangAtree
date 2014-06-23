-module(tr_app).
-behaviour(application).
-export([start/2,stop/1]).

start(_Type,_StartArgs) ->		%_StartArgs为tcpopt.app的传给mod的参数
	case tr_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Other ->
			{error,Other}
	end.

stop(_State) ->
	ok.