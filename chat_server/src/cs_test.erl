-module(cs_test).
-export([print/1]).

print(Value) ->
	io:format("~n~p~n",[Value]).