-module(sc_element_sup).
-behaviour(supervisor).
%%API
-export([start_link/0,start_child/2]).
%%supervisor callback
-export([init/1]).

-define(SERVER,?MODULE).

start_link() ->
	supervisor:start_link({local,?SERVER},?MODULE,[]).   %启动监督者

start_child(Value,LeaseTime) ->
	supervisor:start_child(?SERVER,[Value,LeaseTime]).

init([]) ->
	Element = {sc_element,{sc_element,start_link,[]},temporary,brutal_kill,worker,[sc_element]}, %指明如何启动和管理子进程
	Children = [Element],
	RestartStrategy = {simple_one_for_one,0,1},  %指明监督者的行为
	{ok,{RestartStrategy,Children}}. %返回监督规范