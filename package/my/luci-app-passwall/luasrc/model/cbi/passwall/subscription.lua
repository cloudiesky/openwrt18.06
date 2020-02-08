local e = require "nixio.fs"
local e = require "luci.sys"
-- local t = luci.sys.exec("cat /usr/share/passwall/dnsmasq.d/gfwlist.conf|grep -c ipset")

m = Map("passwall")
-- [[ Other Settings ]]--
s = m:section(TypedSection, "global_other",translate("Add the node via the link"))
s.anonymous = true


---- Auto Ping
o = s:option(Flag, "auto_ping", translate("Auto Ping"),
             translate("This will automatically ping the node for latency"))
o.default = 1

---- Use TCP Detection delay
o = s:option(Flag, "use_tcping", translate("Use TCP Detection delay"),
             translate("This will use tcping replace ping detection of node"))
o.default = 1

---- Concise display nodes
o = s:option(Flag, "compact_display_nodes", translate("Concise display nodes"))
o.default = 0

---- Show Add Mode
o = s:option(Flag, "show_add_mode", translate("Show Add Mode"))
o.default = 1

---- Show group
o = s:option(Flag, "show_group", translate("Show Group"))
o.default = 1

-- [[ Add the node via the link ]]--
s:append(Template("passwall/node_list/link_add_node"))


-- [[ Subscribe Settings ]]--
s = m:section(TypedSection, "global_subscribe", translate("Node Subscribe"),
              translate(
                  "Please input the subscription url first, save and submit before updating. If you subscribe to update, it is recommended to delete all subscriptions and then re-subscribe."))
s.anonymous = true

---- Subscribe via proxy
o = s:option(Flag, "subscribe_proxy", translate("Subscribe via proxy"))
o.default = 0
o.rmempty = false

---- Enable auto update subscribe
o = s:option(Flag, "auto_update_subscribe",
             translate("Enable auto update subscribe"))
o.default = 0
o.rmempty = false

---- Week update rules
o = s:option(ListValue, "week_update_subscribe", translate("Week update rules"))
o:value(7, translate("Every day"))
for e = 1, 6 do o:value(e, translate("Week") .. e) end
o:value(0, translate("Week") .. translate("day"))
o.default = 0
o:depends("auto_update_subscribe", 1)

---- Day update rules
o = s:option(ListValue, "time_update_subscribe", translate("Day update rules"))
for e = 0, 23 do o:value(e, e .. translate("oclock")) end
o.default = 0
o:depends("auto_update_subscribe", 1)

---- Manual subscription
o = s:option(Button, "_update", translate("Manual subscription"))
o.inputstyle = "apply"
function o.write(e, e)
    luci.sys
        .call("nohup /usr/share/passwall/subscription.sh > /dev/null 2>&1 &")
    luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "passwall",
                                                 "log"))
end

---- Subscribe Delete All
o = s:option(Button, "_stop", translate("Delete All Subscribe Node"))
o.inputstyle = "remove"
function o.write(e, e)
    luci.sys.call("/usr/share/passwall/subscription.sh stop")
    luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "passwall",
                                                 "log"))
end

s = m:section(TypedSection, "subscribe_list")
s.addremove = true
s.anonymous = true
s.sortable = true
s.template = "cbi/tblsection"

o = s:option(Flag, "enabled", translate("Enabled"))
o.rmempty = false

o = s:option(Value, "remark", translate("Subscribe Remark"))
o.width = "auto"
o.rmempty = false

o = s:option(Value, "url", translate("Subscribe URL"))
o.width = "auto"
o.rmempty = false

return m


