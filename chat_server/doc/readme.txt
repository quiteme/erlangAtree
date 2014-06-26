cs_test:print("") 打日志
cs_test:print_debug
application:start(chat_server).
chat_server:insert_chatter("a1").
chat_server:create_channel("a1","c1","channel").
c(hello).