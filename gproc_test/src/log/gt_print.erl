-module(gt_print).
-export([print_info/1,
		format_info/1]).

print_info(Info) ->
	error_logger:info_msg("~n~p~n",[Info]).

format_info(Info) ->
	error_logger:info_msg("#################################################"),
	error_logger:info_msg("~n~p~n",[Info]),
	error_logger:info_msg("#################################################").