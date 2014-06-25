%% -*- mode:Erlang; fill-column:75;comment-column:50;-*-

{application,simple_cache,
[{description,"RPC server for Erlang and OTP in action"},
 {vsn,"0.1.0"},
 {modules,[sc_app,sc_sup,sc_element_sup,sc_event_logger,sc_element,sc_event,sc_store,simple_cache]}, %项目的包含模块
 {registered,[sc_sup]},
 {applications,[kernel,stdlib]},   %项目的依赖库
 {mod,{sc_app,[]}}
]}.