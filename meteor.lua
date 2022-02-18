
print("\nloading meteor.lua")

local private = {
	meteorVelocity = 1,	
	meteorScore = {},
	meteorsArray = {},
	maxOfMeteorArray = 8,
	meteorImage = nil,
}


function private.resetMeteorScore(amountOfPLayers)
	print("amountOfPLayers="..amountOfPLayers)
	if amountOfPLayers == nil then return end
	private.meteorScore = {}
    for i=1, amountOfPLayers do
        private.meteorScore[i] = 0
    end
end


function private.createMeteors(_x, _y)
    -- not spawn more meteors if all of maxOfMeteorArray are still visible 
    if #private.meteorsArray > private.maxOfMeteorArray then
        return
    end
    local l_weight = math.random(0.5, 1.5)

    local meteor = {
        weight = l_weight, --= math.random(0.5, 1.5), --creating meteors with different sizes
        w = l_weight * private.meteorImage:getWidth()   -3, --fixing png size transparency
        h = l_weight * private.meteorImage:getHeight()  -3, --fixing png size transparency
        x = _x,  y = _y,
        angle = math.random(-0.785398, 0.785398) -- -45º to +45º to rotate meteor image and define (x,y) direction

    }
    table.insert(private.meteorsArray, meteor)
end


function private.moveMeteors()
    for k,localMeteor in ipairs(private.meteorsArray) do
        localMeteor.y = localMeteor.y + private.meteorVelocity + 1/localMeteor.weight
        if localMeteor.angle >= 0 then
            localMeteor.x = localMeteor.x - private.meteorVelocity/2 -- localMeteor.weight --localMeteor.angle
        else
            localMeteor.x = localMeteor.x + private.meteorVelocity/2 -- localMeteor.weight --localMeteor.angle
        end
    end
end


function private.removeNotVisibleMeteors()
    for i=#private.meteorsArray, 1, -1 do
        if private.meteorsArray[i].y > g_windowHeight then
            table.remove(private.meteorsArray, i)
        end 
    end
end

function private.resetMeteorsArray()
	private.meteorsArray = {}
end


return private