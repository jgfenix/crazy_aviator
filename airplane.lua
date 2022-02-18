
print("\nloading airplane.lua")


airplane = {
    velocity = 3,
    shotVelocity=5,

    src = "images/airplane",
    srcExploded = "images/explosao.png",
    imgExploded = nil,
    bulletShotImg = nil,

    allMoveKeys = {--[[player1]] {'w', 'a', 's', 'd'},
                --[[player2]] {'up', 'down', 'left', 'right'}},
    allShotKeys = {{'space'}, {'kp0'--[[numpad zero key]], '0'}},
                
}

    function airplane:new(o)
        o = o or {}
        o.w = 0 --w,h,x,y will be setted on main.lua
        o.h = 0
        o.x = 0
        o.y = 0

        o.shots = {}
        o.life = 5

        o.srcBulletShot="images/bullet_shot.png"

        o.sounds = {}
        o.moveKeys = {}
        o.shotKeys = {}
        self.__index = self
        setmetatable(o, self)
        return o
    end


    function airplane:resetLife()
       self.life = 5
    end


    function airplane:processKey(key)
        -- print("received key="..tostring(key))
        --     -- using 'if' instead of 'elsif' whe can move airplane on diagonals
        if key == "w" or key == "up" then --love.keyboard.isDown('w', 'up') then
            if self.h / 3 + (self.y - self.velocity) > 0 then
                self.y = self.y - self.velocity
            end
        end

        if key == "s" or key == "down" then --love.keyboard.isDown('s', 'down') then
            -- print(self.h.."+".."("..self.y .."   +"..self.velocity..") <"..g_windowHeight.."=".. tostring(self.h + (self.y + self.velocity) < g_windowHeight))
            if self.h + (self.y + self.velocity) < g_windowHeight then
                self.y = self.y + self.velocity
            end
        end
        
        if key == "a" or key == "left" then --love.keyboard.isDown('a', 'left') then
            -- middle of airplane on screen
            if (self.x - self.velocity + self.w/2) > 0 then
                self.x = self.x - self.velocity
            end
        end
        
        if key == 'd' or key == "right" then --love.keyboard.isDown('d', 'right') then
            -- middle of airplane on screen
            if self.w/2 + (self.x + self.velocity) < g_windowWidth then
                self.x = self.x + self.velocity
            end
        end

        if key == 'space' or key == 'kp0' or key == '0' then
            self:doShot()
        end

    end


    function airplane:doShot()
    -- maximum of 5 shots at time
        local sx = .5 --X scale factor to change png size
        local sy = .5 --Y scale factor to change png size
        if #self.shots > 5 then return end

        local shot = {
            x = self.x+(self.w/2)-5,
            y = self.y-self.h, --10
            w = 10*sx, --value of width on png file
            h = 25*sy, --value of height on png file
            sx = sx,
            sy = sy,
        }

      table.insert(self.shots, shot)

        -- self.sounds.one_shot_piu_airplane:play()
        if self.sounds.oneShotAirplane
        	then self.sounds.oneShotAirplane:play() --it will be good to move this to main
        end
    end


    function airplane:move_shots()
        for i=#self.shots, 1, -1 do
            if self.shots[i].y > 0 then
                self.shots[i].y = self.shots[i].y - self.shotVelocity --shot go up
            else
                table.remove(self.shots, i)
            end
        end
    end


return airplane