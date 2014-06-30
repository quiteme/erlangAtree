-module(tr_test).

-include_lib("eunit/include/eunit.hrl").

%add_test() ->
%	4 = add(2,2),
%	6 = add(2,4).

%server_test_()->
%	[
%		test_them_types(),
%		test_them_values()
%	].

server_test_() ->
	{foreach,
	fun start/0,
	fun stop/1,
	%fun do_func/1
	[
		%fun is_registered/1,
		fun get_count/1
	]
	}.

add(A,B) -> A + B.

test_them_types() ->
	?_assert(is_number(add(1,2))).
 
test_them_values() ->
	[
		?_assertEqual(4, add(2,2)),
		?_assertEqual(3, add(1,2)),
		?_assertEqual(2, add(1,1))
	].

start() ->
	?_assertEqual(1,2),
	{ok,Pid} = tr_server:start_link().

stop(_) ->
	?_assertEqual(1,2),
	tr_server:stop().

do_func(Arg) ->
	is_registered(Arg),
	get_count(Arg).

is_registered({ok,Pid}) ->
	[
		?_assert(erlang:is_process_alive(Pid)),
		?_assertEqual(Pid, whereis(tr_server))
	].

get_count({ok,Pid}) ->
	error_logger:info_msg("hello~n"),
	error_logger:info_msg("PID_INFO: ~p~n", [erlang:process_info(Pid)]),
	{ok,Count} = tr_server:get_count(Pid),
	?_assert(is_number(Count)).