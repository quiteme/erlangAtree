-module(gt_factory_test).

-include_lib("eunit/include/eunit.hrl").

chatter_create_drop_test_() ->
	{setup,
	 fun start/0,
	 fun stop/1,
	 fun chatter_tests/1
	}.

start() ->
	application:start(gproc_test).

stop(_Pid) ->
	application:stop(gproc_test).

chatter_tests(_Pid) ->
	C1 = <<"a1">>,
	C2 = <<"a2">>,
	gt_factory:start_chatter(C1),
	gt_factory:start_chatter(C2),

	gt_chatter:join(C1,{world,global}),
	gt_chatter:join(C1,{channel,1}),
	gt_chatter:join(C1,{alliance,2}),
	gt_chatter:join(C1,{team,3}),

	gt_chatter:join(C2,{world,global}),
	gt_chatter:join(C2,{channel,1}),
	gt_chatter:join(C2,{alliance,2}),
	gt_chatter:join(C2,{team,3}),

	gt_chatter:chat(C2,{world,<<"world chat test!">>}),
	gt_chatter:chat(C2,{channel,<<"channel chat test!">>}),
	gt_chatter:chat(C2,{alliance,<<"alliance chat test!">>}),
	gt_chatter:chat(C2,{team,<<"team chat test!">>}),

	gt_factory:shutdown_chatters(),
	[
	?_assertEqual(ok,application:ensure_started(gproc))
	].