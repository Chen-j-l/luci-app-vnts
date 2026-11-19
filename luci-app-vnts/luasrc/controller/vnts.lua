
module("luci.controller.vnts", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/vnts") then
		return
	end
	
	entry({"admin", "vpn", "vnts"}, alias("admin", "vpn", "vnts", "vnts"),_("VNTS"), 44).dependent = true
	entry({"admin", "vpn", "vnts", "vnts"}, cbi("vnts"),_("VNTS"), 45).leaf = true
	entry({"admin", "vpn", "vnts", "get_log"}, call("get_log")).leaf = true
	entry({"admin", "vpn", "vnts", "clear_log"}, call("clear_log")).leaf = true
	entry({"admin", "vpn", "vnts", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e = {}
	local sys  = require "luci.sys"
	local uci  = require "luci.model.uci".cursor()
	local port = tonumber(uci:get_first("vnt", "vnts", "web_port"))
		e.port = (port or 29870)
	local web = tonumber(uci:get_first("vnt", "vnts", "web"))
		e.web = (web or 0)
	e.running = luci.sys.call("pgrep vnts >/dev/null") == 0
	local tagfile = io.open("/tmp/vnts_time", "r")
	if tagfile then
		local tagcontent = tagfile:read("*all")
		tagfile:close()
		if tagcontent and tagcontent ~= "" then
			os.execute("start_time=$(cat /tmp/vnts_time) && time=$(($(date +%s)-start_time)) && day=$((time/86400)) && [ $day -eq 0 ] && day='' || day=${day}天 && time=$(date -u -d @${time} +'%H小时%M分%S秒') && echo $day $time > /tmp/command_vnts 2>&1")
			local command_output_file = io.open("/tmp/command_vnts", "r")
			if command_output_file then
				e.vntsSta = command_output_file:read("*all")
				command_output_file:close()
			end
		end
	end
	local command1 = io.popen('test ! -z "`pidof vnts`" && (top -b -n1 | grep -E "$(pidof vnts)" 2>/dev/null | grep -v grep | awk \'{for (i=1;i<=NF;i++) {if ($i ~ /vnts/) break; else cpu=i}} END {print $cpu}\')')
	e.vntsCpu = command1:read("*all")
	command1:close()
	local command2 = io.popen("test ! -z `pidof vnts` && (cat /proc/$(pidof vnts | awk '{print $NF}')/status | grep -w VmRSS | awk '{printf \"%.2f MB\", $2/1024}')")
	e.vntsRam = command2:read("*all")
	command2:close()
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function get_log()
	local log = ""
	local files = {"/tmp/vnts.log"}
	for i, file in ipairs(files) do
		if luci.sys.call("[ -f '" .. file .. "' ]") == 0 then
			log = log .. luci.sys.exec("cat " .. file)
		end
	end
	luci.http.write(log)
end

function clear_log()
	luci.sys.call("rm -rf /tmp/vnts.log")
end
