-module(cs_test).
-export([print/1,print_debug/1]).
-define(PRINT,1).

print(Value) ->
	if
		?PRINT > 0 -> io:format("~n~p~n",[Value]);
		true -> true
	end.

print_debug(Value) ->
	if
		?PRINT > 0 -> 
			io:format("~n+++++++++++++++++++++++++++++++++++++++"),
			io:format("~n~p~n",[Value]),
			io:format("+++++++++++++++++++++++++++++++++++++++~n");
		true -> true
	end.