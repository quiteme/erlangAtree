-module (first).
-export ([print/1]).
-export ([start/0]).
-export ([test2/0]).
-export ([test3/0]).
-export ([area/1]).
-export ([test4/0]).
-export ([test4/1]).
-export ([sign/1]).

print(Log)->
	io:fwrite("~p~n",[Log]).

start()->
	io:format("hello first !~n").

test2()->
	Users = [
		{person,[
			{name,"Frist","Last"},
			{shoe_size,12},
			{tags,[aaa,bbb,ccc]}
			]
		}
	],
	[{person,[{name,First,Last},{_,Shoe},{_,Tags}]}] = Users,
	io:format("~s ~s ~p ~p~n",[First,Last,Shoe,Tags]),
	[{person,[_,_,{_,[aaa|Tag]}]}] = Users,
	print(Tag).

test3()->
	First = "test",
	Last = "Last",
	Shoe = 12,
	io:format("~s ~s ~w~n",[First,Last,Shoe]).

area({circle,Radius})->			%通过函数的参数模式匹配定义函数的子句（相当于重载）
	Radius*Radius*math:pi();
area({square,Side})->
	Side*Side;
area({rectangle,Height,Width})->
	Height*Width.	

either_or_both(A,B) ->			%case子句可以替代上面的area重载
	case {A,B} of
		{true,B} when is_boolean(B) ->
			true;
		{A,true} when is_boolean(A) ->
			true;
		{false,false} ->
			false 
	end.

test4()->
	case either_or_both(true,false) of
		true ->
			print("yes");
		false ->
			print("no")
	end.

test4(F) ->				%F = fun either_or_both/2. 或者采用匿名函数 test4(fun (A,B) -> A or B end)
	case F(true,false) of
		true ->
			print("yes");
		false ->
			print("no")
	end.

sign(N) when is_number(N) ->   %if 子句的使用
	if 
		N > 0 -> positive;
		N < 0 -> negative;
		true -> zero 
	end.