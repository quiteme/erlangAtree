-module(ranch_test_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
	RanchSupSpec = ?CHILD(ranch_sup, supervisor),
    ListenerSpec = ranch:child_spec(ranch_tcp_listener, 8,
        ranch_tcp, [{port, 5555}, {max_connections, infinity}],
        ranch_conn, []),
    Specs = [RanchSupSpec, ListenerSpec],
    {ok, {{one_for_one, 5, 10}, Specs}}.

