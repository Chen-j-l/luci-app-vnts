local http = luci.http
local nixio = require "nixio"

m = Map("vnts")
m.description = translate('vnt是一个简便高效的异地组网、内网穿透工具。')

m:section(SimpleSection).template  = "vnts/vnts_status"

s = m:section(TypedSection, "vnts", translate("vnts服务器设置"))
s.anonymous = true

s:tab("gen", translate("参数设置"))
s:tab("logs", translate("日志"))

switch = s:taboption("gen", Flag, "enabled", translate("Enable"))
switch.rmempty = false

server_port = s:taboption("gen",Value, "server_port", translate("本地监听端口"))
server_port.datatype = "port"
server_port.optional = false
server_port.placeholder = "29872"


white_Token = s:taboption("gen",DynamicList, "white_Token", translate("Token白名单"),
	translate("填写后将只能指定的token才能连接此服务器，留空则没有限制，所有token都可以连接此服务端"))

subnet = s:taboption("gen",Value, "subnet", translate("指定DHCP网关"),
	translate("分配给vnt-cli客户端的接口IP网段"))
subnet.datatype = "ip4addr"
subnet.placeholder = "10.10.0.1"

servern_netmask = s:taboption("gen",Value, "servern_netmask", translate("指定子网掩码"))
servern_netmask.placeholder = "255.255.255.0"

web = s:taboption("gen",Flag, "web", translate("启用WEB管理"),
	translate("WEB管理界面，图形化显示所有客户端详情"))
web.rmempty = false

web_port = s:taboption("gen",Value, "web_port", translate("WEB端口"))
web_port.datatype = "port"
web_port:depends("web", "1")
web_port.placeholder = "29870"

webuser = s:taboption("gen", Value, "webuser", translate("帐号"),
	translate("WEB管理界面的登录用户名"))
webuser.placeholder = "admin"
webuser:depends("web", "1")
webuser.password = true

webpass = s:taboption("gen", Value, "webpass", translate("密码"),
	translate("WEB管理界面的登录密码"))
webpass.placeholder = "admin"
webpass:depends("web", "1")
webpass.password = true

logs = s:taboption("gen",Flag, "logs", translate("启用日志"),
	translate("运行日志在/tmp/vnts.log，可在上方服务端日志查看"))
logs.rmempty = false

sfinger = s:taboption("gen",Flag, "sfinger", translate("启用数据指纹校验"),
	translate("开启后只会转发指纹正确的客户端数据包，增强安全性，这会损失一部分性能,如果服务端开启指纹校验，则客户端也必须开启。<br>注意：默认情况下服务端不会对中转的数据做校验，如果要对中转的数据做校验，则需要客户端、服务端都开启此参数"))
sfinger.rmempty = false

logs = s:taboption("logs", DummyValue, "logs")
logs.rawhtml = true
logs.template = "vnts/vnts_log"

return m
