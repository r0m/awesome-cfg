-- original code published on https://awesomewm.org/wiki/Active_RAM
-- and on https://awesomewm.org/wiki/CPU_Usage
local wibox = require("wibox")
local awful = require("awful")
local vicious = require("vicious")

-- Create meminfo widget
meminfo = wibox.widget.textbox()

function activeram()
   local active, ramusg, res
   
   for line in io.lines("/proc/meminfo") do
      for key , value in string.gmatch(line, "(%w+):%s+(%d+).+") do
	 if key == "MemTotal" then memtot = tonumber(value)
	 elseif key == "Active" then active = tonumber(value)
	 end
      end
   end
   
   ramusg = (active/memtot)*100
   
   res = string.format("%.2f", (active/1024))
	
   if ramusg < 51 then
      res = '<span color="green">' .. res .. '</span>MB (<span color="green">' .. string.format("%.2f",ramusg) .. '</span>%)'
   elseif ramusg < 71 then
      res = '<span color="yellow">' .. res .. '</span>MB (<span color="green">' .. string.format("%.2f",ramusg) .. '</span>%)'
   elseif ramusg < 86 then 
      res = '<span color="orange">' .. res .. '</span>MB (<span color="green">' .. string.format("%.2f",ramusg) .. '</span>%)'
   else 
      res = '<span color="red">' .. res .. '</span>MB (<span color="green">' .. string.format("%.2f",ramusg) .. '</span>%)'
   end
   
   return res
end

-- Activate timer to update memory info
mem_timer = timer({timeout = 1})
mem_timer:connect_signal("timeout", function() meminfo:set_markup(activeram() .. " | ") end)
mem_timer:start()

-- Create cpuinfo widget
cpuinfo = wibox.widget.textbox()

function cpu_level(widget, cpuusgt)
   local res, cpuusg
   cpuusg = cpuusgt[1]
   if cpuusg < 51 then
      res = '<span color="green">' .. string.format("%.2f",cpuusg) .. '</span>%'
   elseif cpuusg < 71 then
      res = '<span color="yellow">' .. string.format("%.2f",cpuusg) .. '</span>%'
   elseif cpuusg < 86 then 
      res = '<span color="orange">' .. string.format("%.2f",cpuusg) .. '</span>%'
   else 
      res = '<span color="red">' .. string.format("%.2f",cpuusg) .. '</span>%'
   end
   
   return "cpu: " .. res .. " | "
end

vicious.register(cpuinfo,vicious.widgets.cpu, cpu_level)
