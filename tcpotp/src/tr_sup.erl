-module(tr_sup).
-behaviour(supervisor).
%%API
-export([start_link/0]).
%%supervisor callback
-export([init/1]).

-define(SERVER,?MODULE).

start_link() ->
	supervisor:start_link({local,?SERVER},?MODULE,[]).   %启动监督者

init([]) ->
	Server = {tr_server,{tr_server,start_link,[]},permanent,2000,worker,[tr_server]}, %指明如何启动和管理子进程
	Children = [Server],
	RestartStrategy = {one_for_one,0,1},  %指明监督者的行为
	{ok,{RestartStrategy,Children}}. %返回监督规范