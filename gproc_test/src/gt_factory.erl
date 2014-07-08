-module(gt_factory).
-behaviour(gen_server).
%% API
-export([start_link/0,
         shutdown_chatters/0,
         start_chatter/1]).
%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).
-record(state, {}).

-include("include/chat_server_gproc.hrl").
%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

-spec(start_chatter(PlayerID::binary()) -> {ok,pid()}).
start_chatter(PlayerID) ->
    gt_print:print_info({"gt_factory:start_chatter",self()}),
	gen_server:call(?MODULE,{start_chatter,PlayerID}).

shutdown_chatters() ->
    gt_print:print_info({"gt_factory:shutdown_chatters",self()}),
	gen_server:cast(?MODULE,shutdown_chatters).
%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    gt_print:print_info({"gt_factory:init",self()}),
    {ok, #state{}}.

handle_call({start_chatter,PlayerID}, _From, State) ->
    gt_print:print_info({"gt_factory:handle_call(start_chatter)",self()}),
	Result = case ?GET_PID({chatter,PlayerID}) of
		undefined -> gt_chatter_sup:start_child([PlayerID]);
		Pid -> {ok,Pid}
	end,
    {reply,Result,State}.

handle_cast(shutdown_chatters, State) ->
	Children = supervisor:which_children(gt_chatter_sup),
    gt_print:print_info({"gt_factory:handle_cast(shutdown_chatters)",self(),Children}),
    lists:foreach(fun (_Child = {_Name,Pid,_Type,_Module}) ->
                    Pid ! {shutdown,self()} 
                  end,Children),
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.