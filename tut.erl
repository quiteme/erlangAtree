-module(tut).
-export([fac/1]).
-export([do_sum/1]).
-export([sum/1]).
-export([rev/1]).
-export([do_rev/1]).
-export([tailrev/1]).
-export([run/0]).
-export([test/0]).
-export([test1/0]).

fac(0) -> 1;
fac(N) -> N*fac(N-1).

do_sum(N,Total)->				%是否属于尾递归？
	case{N,Total} of
		{0,Total} -> Total;
		{N,Total} -> do_sum(N-1,Total+N)
	end.

do_sum(N) when is_number(N) ->
	do_sum(N,0).
	
sum(N) when is_number(N) ->
	if 
		N > 0 -> sum(N-1)+N;		%是否属于尾递归？
		N =:= 0 -> 0
	end.

rev([])->[];
rev([X])->[X];
rev([A|[B|Other]])->rev(Other) ++ [B,A].

do_rev([A|Other])->do_rev(Other) ++ [A];
do_rev([])->[].

%尾排序 效率更高 相当于新建一个有序列表，因此避免了元素的移位操作
do_tailrev([X|Other],Acc)->do_tailrev(Other,[X|Acc]);
do_tailrev([],Acc)->Acc.

tailrev(List)->do_tailrev(List,[]).

run() ->
	rpc:call('a@chizeshengdeMac-mini.local',emysql,add_pool,[hello_pool, 1,"root", "123", "localhost", 3306,"hello_database", utf8]),
    %emysql:add_pool(hello_pool, 1,
    %    "root", "123", "localhost", 3306,
    %    "hello_database", utf8),

	rpc:call('a@chizeshengdeMac-mini.local',emysql,execute,[hello_pool,<<"INSERT INTO hello_table SET hello_text = 'Hello World!'">>]),
   	%emysql:execute(hello_pool,
    %    <<"INSERT INTO hello_table SET hello_text = 'Hello World!'">>),

	Result = rpc:call('a@chizeshengdeMac-mini.local',emysql,execute,[hello_pool,<<"select hello_text from hello_table">>]),
    %Result = emysql:execute(hello_pool,
    %    <<"select hello_text from hello_table">>),
    io:format("~n~p~n", [Result]).

test() ->
	Filters = [{fun dtest/1,["a1"]},{fun dtest/1,["a2"]}],
	Result = run_filters(Filters),
	io:format("~n~p~n",[Result]).

run_filters([{Fun,[Args]}|Filters]) ->
	case Fun(Args) of 
		{error,Msg} -> {error,Msg};
		Result ->
			[Result | run_filters(Filters)]
	end;
run_filters([]) -> [ok].

dtest(Arg) ->
	{ok,Arg}.

test1() ->
	%{MeSec,Sec,MiSec} = os:timestamp(),
	%{MeSec,Sec,MiSec} = now(),
	%Microseconds = 1000000 * MeSec + Sec * 1000 + MiSec,
	Microseconds = calendar:datetime_to_gregorian_seconds(now()),
	io:format("~n~p~n",[Microseconds]),

	Now = calendar:local_time(),
	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
	io:format("~n~p~n",[CurrentTime]).