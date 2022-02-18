--need this to output on console on windows (using cmd)
local debugEnabled = false

function love.conf(t)
	t.console = debugEnabled
end


function IN()
	if debugEnabled then print("IN "..debug.getinfo(2,'S').source..":"..debug.getinfo(2, 'l').currentline) end
end


function OUT()
	if debugEnabled then print("OUT "..debug.getinfo(2,'S').source..":"..debug.getinfo(2, 'l').currentline) end
end