-module(hello).

-export([test/0]).

test() ->
	application:start(ranch_test),
	ranch_client:test_msg(<<"this is a test msg!">>).