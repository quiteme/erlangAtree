-module(gt_chatter_sup).

-behaviour(supervisor).

%% API
-export([start_link/0,start_child/1]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start_child(Args) ->
	gt_print:print_info("gt_chatter_sup:start_child"),
	supervisor:start_child(?MODULE,[Args]).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
	GtChatter = ?CHILD(gt_chatter,worker),
    {ok, {{simple_one_for_one, 0, 1}, [GtChatter]}}.