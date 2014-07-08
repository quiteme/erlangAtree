-module(gt_chatter).
-behaviour(gen_server).
%% API
-export([start_link/1,
         join/2,
         chat/2]).
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

start_link([PlayerID]) ->
    gt_print:print_info({"gt_chatter:start_link",PlayerID}),
    gen_server:start_link(?MODULE, [PlayerID],[]).

join(Player,{world,Gid}) ->
    Pid = player_pid(Player),
    Type = {world,Gid},
    gen_server:cast(Pid,{join,Type});
join(Player,{channel,Cid}) ->
    Pid = player_pid(Player),
    Type = {channel,Cid},
    gen_server:cast(Pid,{join,Type});
join(Player,{alliance,Aid}) ->
    Pid = player_pid(Player),
    Type = {alliance,Aid},
    gen_server:cast(Pid,{join,Type});
join(Player,{team,Tid}) ->
    Pid = player_pid(Player),
    Type = {team,Tid},
    gen_server:cast(Pid,{join,Type});
join(_Player,_Type) ->
    ok.

chat(Player,{world,Msg}) ->
    Pid = player_pid(Player),
    Type = {world,Msg},
    gen_server:cast(Pid,{chat,Type});
chat(Player,{channel,Msg}) ->
    Pid = player_pid(Player),
    Type = {channel,Msg},
    gen_server:cast(Pid,{chat,Type});
chat(Player,{alliance,Msg}) ->
    Pid = player_pid(Player),
    Type = {alliance,Msg},
    gen_server:cast(Pid,{chat,Type});
chat(Player,{team,Msg}) ->
    Pid = player_pid(Player),
    Type = {team,Msg},
    gen_server:cast(Pid,{chat,Type});
chat(_Player,_Msg) ->
    ok.

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([PlayerID]) ->
    gt_print:print_info({"gt_chatter:init",PlayerID}),
	?REG_PID({chatter,PlayerID}),   % 注册全局的gproc 方便查询
	put(player_id,PlayerID),		% 注册线程dict 方便使用
	process_flag(trap_exit, true),	% 设置拦截退出消息
    {ok, #state{}}.

handle_call(_Info, _From, State) ->
    {reply,{ok},State}.

handle_cast({join,{Type,Id}}, State) ->
    ?SUBSCRIBE({Type,Id}),
    put(Type,Id),
    {noreply, State};
handle_cast({chat,{Type,Msg}}, State) ->
    case get_channel(Type) of
        {error,Result} -> {error,Result};
        {Type,Id} -> ?PUBLISH({Type,Id},{gproc_chat,Msg})
    end,
    {noreply, State}.

handle_info({gproc_chat,Msg}, State) ->
    gt_print:format_info({"receive Msg:",Msg}),
    {noreply, State};
handle_info({shutdown,_From}, State) ->
    gt_print:print_info({"gt_chatter:handle_info(shutdown)",self()}),
    {stop,shutdown,State}.

terminate(_Reason, _State) ->
    gproc:goodbye(),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%=================================================================== 
player_pid(PlayerId) ->
    case ?GET_PID({chatter,PlayerId}) of 
        undefined ->
            {ok,Pid} = gt_factory:start_chatter(PlayerId),
            Pid;
        Pid -> Pid 
    end. 

get_channel(Type) ->
    case get(Type) of 
        undefined -> {error,not_join_this};
        Id -> {Type,Id}
    end.