-module(cs_app).
-behaviour(application).
-export([start/2,stop/1]).

start(_Type,_StartArgs) ->		%_StartArgs为tcpopt.app的传给mod的参数
	cs_test:print("cs_app.erl start"),
	cs_channel_store:init(),
	cs_chatter_store:init(),
	case cs_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Other ->
			{error,Other}
	end.

stop(_State) ->
	ok.