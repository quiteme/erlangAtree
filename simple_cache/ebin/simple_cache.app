%% -*- mode:Erlang; fill-column:75;comment-column:50;-*-

{application,simple_cache,
[{description,"RPC server for Erlang and OTP in action"},
 {vsn,"0.1.0"},
 {modules,[sc_app,sc_sup,sc_server]},
 {registered,[sc_sup]},
 {applications,[kernel,stdlib]},
 {mod,{sc_app,[]}}
]}.