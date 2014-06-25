-module(cs_sup).
-behaviour(supervisor).
%%API
-export([start_link/0]).
%%supervisor callback
-export([init/1]).

-define(SERVER,?MODULE).

start_link() ->
	cs_test:print("cs_sup.erl start_link"),
	supervisor:start_link({local,?SERVER},?MODULE,[]).   %启动监督者

init([]) ->
	cs_test:print("cs_sup.erl init"),
	Channel = {cs_channel_sup,{cs_channel_sup,start_link,[]},permanent,2000,worker,[cs_channel_sup]},
	Chatter = {cs_chatter_sup,{cs_chatter_sup,start_link,[]},permanent,2000,worker,[cs_chatter_sup]},
	Children = [Channel,Chatter],
	RestartStrategy = {one_for_one,4,3600},  %指明监督者的行为
	{ok,{RestartStrategy,Children}}. %返回监督规范