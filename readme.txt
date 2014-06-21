erlang运行时系统（ERTS）
erlang虚拟机（BEAM）
erlang VM = ERTS + BEAM

git 上传流程
git add --all
git commit -am "message"
git status (检查状态用，可忽略)
git push origin master

shell 指令
shell中的编号增涨了，表示v中的值增加了
exp:1.
	v(1) = 1
	X=2.
	v(2) = 2

Erlang的运算符
+ - * 
/ 返回浮点数的除法
div 返回整数的除法 
rem 返回余数(不支持浮点数运算)
bsl 左移
bsr 右移
band 逻辑和
bor  逻辑或
bxor 逻辑异或
bnot 逻辑非
> < ==(算数相等) /=(算数不等) =:=(完全相等) =/=(不完全相等) >= =<

数值 < 原子(相当于enum，（单引号可略）小写字符串) < 元祖（{}） < 列表（字符串也是列表）（[]）

同名函数 只要参数个数不同 即为不同函数 函数全名为（函数名/参数个数）

系统模块：
	erlang 核心模块
	lists 负责对list的操作
	io 负责基本的文本输入输出处理
	dict(字典) 提供基于散列的关联数组
	array 可扩展，带整数索引的数组

erlc -o ./ebin hello.erl

= 模式匹配运算符
_ 省略模式（占位符）
$ 获取字符的编码值

字符串++运算符
"abc" ++ SomeString =:= [$a,$b,$c | SomeString]

try ... catch ... end
try ... of ... catch ... end
try ... after ... end  %不管有没有异常 after中的部分都回执行

%[{area,H*W} || {rectangle,H,W} <- Shapes,H*W >= 10]
%创建一个集合，其范围为面积大于10的矩形，此处为{rectangle,H,W}去匹配Shapes中所有的形状，找出满足条件的

<- 从列表中选取元素 exp: << <<X:3>> || X <- [1,2,3,4,5,6,7] >>
<= 从位串中提取内容 exp：[x || <<X:3>> <= <<41,203,23:5>>]

记录声明
-record(customer,{name="<anonymous>",address,phone}).
创建记录
#customer{}
R = #customer{phone="55555555"}
访问记录
R#customer.phone -> "55555555"  %直接访问
记录的修改
R#customer{name="aaaa aaaa",address="vvbbv sv s s"}