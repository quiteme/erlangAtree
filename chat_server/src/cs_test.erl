-module(cs_test).
-export([print/1,print_debug/1]).

print(Value) ->
	io:format("~n~p~n",[Value]).

print_debug(Value) ->
	io:format("~n+++++++++++++++++++++++++++++++++++++++"),
	io:format("~n~p~n",[Value]),
	io:format("+++++++++++++++++++++++++++++++++++++++~n").