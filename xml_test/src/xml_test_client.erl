-module(xml_test_client).
-export([start/0]).

start() ->
	application:start(xml_test),
	xml_test_server:load_xml("config/multi.xml"),
	Price = xml_test_server:get_price(apple),
	error_logger:info_msg("Price:~p",[Price]),
	Users = xml_test_server:get_prop_list(pear),
	error_logger:info_msg("Users:~p",[Users]),
	Prop = xml_test_server:find_prop(orange,<<"user2">>),
	error_logger:info_msg("Prop:~p",[Prop]).