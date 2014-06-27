-module (hello).
-export ([start/0]).
-export ([run/0]).
-export ([test1/0]).
-export ([area/1,list_remove_one/2]).

start()->
	io:format("erlang!~n"),
	spawn(io, format, ["erlang!"]), 
	first:start().

run()->
	Pid = spawn(fun ping/0),  %spawn的重载 调函数引用
	Pid ! self(),             %发送 (目的地 ！消息)
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