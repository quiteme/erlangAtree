-module(tut).
-export([fac/1]).
-export([do_sum/1]).
-export([sum/1]).
-export([rev/1]).
-export([do_rev/1]).
-export([tailrev/1]).

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