-module(test).

-include_lib("eunit/include/eunit.hrl").

add(A,B) -> A + B.

add_test() ->
	4 = add(2,2),
	6 = add(2,4).

new_add_test() ->
	?assertEqual(4, add(2,2)),
	?assertEqual(3, add(1,2)),
	?assert(is_number(add(1,2))).

%add_test_() ->
%	[
%		test_them_types(),
%		test_them_values(),
%		?_assertError(badarith, 1/0)
%	].

new_add_test_() ->
	{setup,
	fun start/0,
	fun stop/0
	}.
 
test_them_types() ->
	?_assert(is_number(add(1,2))).
 
test_them_values() ->
	[
		?_assertEqual(4, add(2,2)),
		?_assertEqual(3, add(1,2)),
		?_assertEqual(3, add(1,1))
	].

start() ->
	?_assert(is_number(add(1,2))).

stop() ->
	[
		?_assertEqual(4, add(2,2)),
		?_assertEqual(3, add(1,2)),
		?_assertEqual(3, add(1,1))
	].

get_test_list() -> 
	["abc", 
	 "ace", 
	 "dac", 
	 "fdc", 
	 "ecf"].


