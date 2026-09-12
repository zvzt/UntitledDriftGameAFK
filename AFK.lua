-- Who's Zot?

if getgenv().StayAFK then return end
getgenv().StayAFK=true

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local AFKEvent=ReplicatedStorage:WaitForChild("AFKEvent")
local old
old=hookmetamethod(game,"__namecall",newcclosure(function(self,...)
	local args={...}
	local method=getnamecallmethod()

	if getgenv().StayAFK and method=="FireServer" and self==AFKEvent and args[1]==false then
		return
	end

	return old(self,...)
end))

AFKEvent:FireServer(true,0)
task.spawn(function()
	while getgenv().StayAFK do
		AFKEvent:FireServer(true,0)
		task.wait(5)
	end
end)
print("AFK Mode ON")
