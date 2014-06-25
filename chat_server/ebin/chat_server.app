%% -*- mode:Erlang; fill-column:75;comment-column:50;-*-

{application,chat_server,
[{description,"tcp/ip chat server!"},
 {vsn,"0.1.0"},
 {modules,[cs_app,cs_sup,cs_channel_sup,cs_chatter_sup,cs_channel,
 	cs_chatter,cs_channel_store,cs_chatter_store,chat_server,cs_test]}, %项目的包含模块
 {registered,[sc_sup]},
 {applications,[kernel,stdlib]},   %项目的依赖库
 {mod,{cs_app,[]}}
]}.