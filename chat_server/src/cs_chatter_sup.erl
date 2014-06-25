-module(cs_chatter_sup).
-behaviour(supervisor).
%%API
-export([start_link/0,start_child/0]).
%%supervisor callback
-export([init/1]).

-define(SERVER,?MODULE).

start_link() ->
	cs_test:print("cs_chatter_sup.erl start_link"),
	supervisor:start_link({local,?SERVER},?MODULE,[]).   %启动监督者

start_child() ->
	cs_test:print("cs_chatter_sup.erl start_child"),
	supervisor:start_child(?SERVER,[]).

init([]) ->
	cs_test:print("cs_chatter_sup.erl init"),
	Element = {cs_chatter,{cs_chatter,start_link,[]},temporary,brutal_kill,worker,[cs_chatter]}, %指明如何启动和管理子进程
	Children = [Element],
	RestartStrategy = {simple_one_for_one,0,1},  %指明监督者的行为
	{ok,{RestartStrategy,Children}}. %返回监督规范