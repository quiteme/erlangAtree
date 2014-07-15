-module(xml_test_server).
-behaviour(gen_server).
%% API
-export([start_link/0,load_xml/1,get_price/1,get_prop_list/1,find_prop/2]).
%%gen_server callbacks
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2,code_change/3]).
-include_lib("xmerl/include/xmerl.hrl"). 
-record (state,{data}). 
-define(SERVER, ?MODULE).

%%%==========================================
%%% API
%%%==========================================
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

load_xml(Path) ->
	gen_server:cast(?SERVER,{load_xml,Path}).

get_price(Term) ->
	gen_server:call(?SERVER,{get_price,Term}).

get_prop_list(Term) ->
	gen_server:call(?SERVER,{prop_list,Term}).

find_prop(Term,Key) ->
	gen_server:call(?SERVER,{find_prop,Term,Key}).

%%%==========================================
%%% gen_server callbacks
%%%==========================================
init([]) ->
	{ok,#state{data = undefined}}.

handle_call({get_price,Term},_From,State=#state{data = Data}) ->
	Result = case Term of %%此处省略对 Data =:= undefined 的判断
		apple -> 
			[{Term,{price,Value},_},_,_] = Data,
			{Term,price,Value};
		orange ->
			[_,{Term,{price,Value},_},_] = Data,
			{Term,price,Value};
		pear ->
			[_,_,{Term,{price,Value},_}] = Data,
			{Term,price,Value};
		_ -> {error,not_found}
	end,
	{reply,Result,State};
handle_call({prop_list,Term},_From,State=#state{data = Data}) ->
	Result = get_lists(Term,Data),
	{reply,Result,State};
handle_call({find_prop,Term,Key},_From,State=#state{data = Data}) ->
	Result = case get_lists(Term,Data) of 
		{Term,Lists} -> proplists:append_values({name,Key},Lists);
		Res -> Res
	end,
	{reply,[{name,Key}|Result],State}.

handle_cast({load_xml,Path},State) ->
	Data = exec_xml(Path),
	{noreply,State#state{data = Data}}.

handle_info(_,State) ->
	{ok,State}.

terminate(_Reason,_State) ->
	ok.

code_change(_OldVsn,State,_Extra) ->
	{ok,State}.

%%%==========================================
%%% Internal functions
%%%==========================================
exec_xml(Path) ->
	case xmerl_scan:file(Path,[{encoding,'utf-8'}]) of
		{error,_} -> {error,not_found};
		{XmlDoc,_} -> parse_xml(XmlDoc)
	end.

parse_xml(XmlDoc) ->
	[Apple | _] = xmerl_xpath:string("/fruit/apple",XmlDoc),
	[#xmlAttribute{value = SAPrice}] = xmerl_xpath:string("/apple/@price", Apple),
	{ApplePrice,_} = string:to_integer(SAPrice),
	AUsers =  xmerl_xpath:string("/apple/user",Apple),
	AUser = lists:foldl(fun(Item, Tot) ->
                    [#xmlAttribute{value = Name}] = xmerl_xpath:string("/user/@name", Item),
                    [#xmlText{value = SValue}] = xmerl_xpath:string("/user/text()", Item),
                    {Value, _} = string:to_integer(SValue),
                    [{{name,list_to_binary(Name)},{value,Value}}|Tot]
                end,[], AUsers),

	[Orange | _] = xmerl_xpath:string("/fruit/orange",XmlDoc),
	[#xmlAttribute{value = SOPrice}] = xmerl_xpath:string("/orange/@price", Orange),
	{OrangePrice,_} = string:to_integer(SOPrice),
	OUsers =  xmerl_xpath:string("/orange/user",Orange),
	OUser = lists:foldl(fun(Item, Tot) ->
                    [#xmlAttribute{value = Name}] = xmerl_xpath:string("/user/@name", Item),
                    [#xmlText{value = SValue}] = xmerl_xpath:string("/user/text()", Item),
                    {Value, _} = string:to_integer(SValue),
                    [{{name,list_to_binary(Name)},{value,Value}}|Tot]
                end,[], OUsers),

	[Pear | _] = xmerl_xpath:string("/fruit/pear",XmlDoc),
	[#xmlAttribute{value = SPPrice}] = xmerl_xpath:string("/pear/@price", Pear),
	{PearPrice,_} = string:to_integer(SPPrice),
	PUsers =  xmerl_xpath:string("/pear/user",Pear),
	PUser = lists:foldl(fun(Item, Tot) ->
                    [#xmlAttribute{value = Name}] = xmerl_xpath:string("/user/@name", Item),
                    [#xmlText{value = SValue}] = xmerl_xpath:string("/user/text()", Item),
                    {Value, _} = string:to_integer(SValue),
                    [{{name,list_to_binary(Name)},{value,Value}}|Tot]
                end,[], PUsers),
	%error_logger:info_msg("~nResult:~n~p~n",[{apple,{price,ApplePrice},AUser},{orange,{price,OrangePrice},OUser},{pear,{price,PearPrice},PUser}]),
	[{apple,{price,ApplePrice},AUser},{orange,{price,OrangePrice},OUser},{pear,{price,PearPrice},PUser}].

get_lists(Term,Data) ->
	case Term of 
		apple -> 
			[{Term,_,Users},_,_] = Data,
			{Term,Users};
		orange ->
			[_,{Term,_,Users},_] = Data,
			{Term,Users};
		pear ->
			[_,_,{Term,_,Users}] = Data,
			{Term,Users};
		_ -> {error,not_found}
	end.

% parse_xml(Path) ->
% 	{XmlDoc,_} = xmerl_scan:file(Path),
% 	error_logger:info_msg("XmlDoc:~p",[XmlDoc]),
% 	Apples = xmerl_xpath:string("/fruit/apple",XmlDoc),
% 	Apple = lists:foldl(fun(Item, Tot) ->
%                     [#xmlAttribute{value = SPrice}] = xmerl_xpath:string("/apple/@price", Item),
%                     {Price, _} = string:to_integer(SPrice),
%                     [#xmlAttribute{value = SValue}] = xmerl_xpath:string("/apple/@value", Item),
%                     {Value, _} = string:to_integer(SValue),
%                     [{{price,Price},{value,Value}}|Tot]
%                 end,[], Apples),
% 	error_logger:info_msg("XmlApple:~p",[Apple]),
% 	Oranges = xmerl_xpath:string("/fruit/orange",XmlDoc),
% 	Orange = lists:foldl(fun(Item, Tot) ->
%                     [#xmlAttribute{value = SPrice}] = xmerl_xpath:string("/orange/@price", Item),
%                     {Price, _} = string:to_integer(SPrice),
%                     [#xmlAttribute{value = SValue}] = xmerl_xpath:string("/orange/@value", Item),
%                     {Value, _} = string:to_integer(SValue),
%                     [{{price,Price},{value,Value}}|Tot]
%                 end,[], Oranges),
% 	error_logger:info_msg("XmlOrange:~p",[Orange]),
% 	Pears = xmerl_xpath:string("/fruit/pear",XmlDoc),
% 	Pear = lists:foldl(fun(Item, Tot) ->
%                     [#xmlAttribute{value = SPrice}] = xmerl_xpath:string("/pear/@price", Item),
%                     {Price, _} = string:to_integer(SPrice),
%                     [#xmlAttribute{value = SValue}] = xmerl_xpath:string("/pear/@value", Item),
%                     {Value, _} = string:to_integer(SValue),
%                     [{{price,Price},{value,Value}}|Tot]
%                 end,[], Pears),
% 	error_logger:info_msg("XmlPear:~p",[Pear]),

% 	error_logger:info_msg("Result:~p",[{apple,Apple},{orange,Orange},{pear,Pear}]).
	




