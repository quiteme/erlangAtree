-module (hello).
-export ([start/0]).
-export ([run/0]).
-export ([test1/0,test2/0,test3/0,test4/1,test5/0, test6/0]).
-export ([area/1,list_remove_one/2]).

-record(tset_rec, {rec1,rec2}).

start()->
	io:format("erlang!~n"),
	spawn(io, format, ["erlang!"]), 
	first:start().

run()->
	Pid = spawn(fun ping/0),  %spawn的重载 调函数引用
	Pid ! self(),             %发送 (目的地 ！消息)1
	receive
		pong -> ok
	end.

ping()->
	receive
		From -> From ! pong    %接收方From包含了发送方ID
	end.

test1()->
	X=[1,2,'a',1,3,1,2,"a",2,31,2,3,1],
	Y = lists:sort(X),
	lists:reverse(Y).      %一旦赋值，变量值不会改变

area(Shape)->				%使用case子句 替代如first.erl中的area函数重载
	case Shape of
		{circle,Radius} ->
			Radius*Radius*math:pi();
		{square,Side} ->
			Side*Side;
		{rectangle,Height,Width} ->
			Height*Width
	end.

list_remove_one(List,One) when is_list(List) ->
	[X || X <- List , X =/= One].

test2() ->
	Test = #tset_rec{rec1 = 1},
	NewTest = update_rec2([Test]),
	io:format("ffffffffff:~n~p~n",[NewTest]).

update_rec2([Test]) -> Test#tset_rec{rec2 = 2}.

test3() ->
	List = [<<"1">>,<<"2">>,<<"3">>],
	DictList = [{binary_to_integer(X),1} || X <- List],
	Dict = dict:from_list(DictList),
	NewList = dict:to_list(Dict),
	io:format("Dict:~p~n",[NewList]).

test4(Daily) ->
	NowDate = erlang:date(),
	case Daily of 
		{_Days,NowDate} -> {fail,error};
		_ -> ok 
	end. 
	% {_,Date} = Daily,
	% NowDate = erlang:date(), 
	% if
	% 	NowDate =:= Date -> {fail,error};
	% 	true -> ok
	% end.

test5() ->
	Dict = dict:new(),
	Dict1 = dict:store(<<"user1">>, 100, Dict),
	Dict2 = dict:store(<<"user2">>, 200, Dict1),
	Dict3 = dict:store(<<"user3">>, 100, Dict2),
	io:format("Dict:~p~n", [Dict3]),
	List = dict:to_list(Dict3),
	io:format("List:~p~n", [List]),
	NewList = lists:sort(fun({_KeyA, ValueA}, {_KeyB, ValueB}) ->
					if 
						ValueA >= ValueB -> true;
						true -> false
					end
			   end, List),
	io:format("SortList:~p~n", [NewList]).

test6() ->
	test6_1(<<"Test123">>).

test6_1(ConfStr) ->
	error_logger:info_msg("Test6~p~n", [ConfStr]).
