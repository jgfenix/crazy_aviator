-- using Lua Löve 11.4 64b
-- using Lua 5.3.6 win32

----------------------------------------------------------------
require "airplane"
g_meteor = require "meteor"

g_gameOver = false

g_windowWidth, g_windowHeight = 320, 480
g_hideMenu = false
g_gamming = false

g_explosionAirplane = nil
g_oneShotAirPlane = nil
g_oneShotPiuAirplane = nil

g_players = {}
table.insert(g_players, airplane:new(nil)) --1 player
----------------------------------------------------------------

function detectAirplaneMeteorsColision(_players, _meteorsArray)
    --improve to create collison array with size of players
    local collision = {0,0} --detect just first collision if there's two meteors one in z index differ of another that we cannot see
    for playerNumber,a in ipairs(_players) do
        for meteorsArrayIndex=#_meteorsArray, 1, -1 do
            m = _meteorsArray[meteorsArrayIndex]

            ret =   m.x < a.x + a.w and
                    a.x < m.x + m.w and
                    a.y < m.y + m.h and
                    m.y < a.y + a.h

            if ret then
                table.remove(_meteorsArray, meteorsArrayIndex)
                collision[playerNumber] =  collision[playerNumber] + 1
            end
        end
    end
    return collision
end


function detectBulletsMeteorsColision(_players, _meteorsArray)
    --improve to create collison array with size of players
    local crashAmount = {0,0}
    for playerNumber, player in ipairs(_players) do
        for k=#player.shots, 1, -1 do
            s=player.shots[k]
            for meteorsArrayIndex=#_meteorsArray, 1, -1 do
                m = _meteorsArray[meteorsArrayIndex]

                ret =   m.x < s.x + s.w and
                        s.x < m.x + m.w and
                        s.y < m.y + m.h and
                        m.y < s.y + s.h

                if ret then
                    table.remove(_meteorsArray, meteorsArrayIndex)
                    table.remove(player.shots, k) --at first will remove shot to not crash with others meteors,in future, powerfull weapon crash others meteors
                    crashAmount[playerNumber] = crashAmount[playerNumber] + 1 --diff player1 from player2
                end
            end
        end
    end
    return crashAmount
end


function own_love_print(text, x, y, r, g, b, rotation, scaleFactor)
    love.graphics.setColor(r, g, b)
    love.graphics.print(text, x, y, rotation, scaleFactor)
    love.graphics.setColor(1, 1, 1)
end


function gameMenu(hide)
    if hide then return end
    love.graphics.setColor(1, 1, 1, 1)
    own_love_print("Players:", g_windowWidth/3.5, g_windowHeight/4, 0, 0, 0, 0, 3)
    -- own_love_print("1 - Press num 1", g_windowWidth/4.8, g_windowHeight/4+50, 0, 0, 0, 0, 2)
    -- own_love_print("2 - Press num 2", g_windowWidth/4.8, g_windowHeight/4+75, 0, 0, 0, 0, 2)
    own_love_print("1 - Press num 1 [w a s d space]", g_windowWidth/18, g_windowHeight/4+50, 0, 0, 0, 0, 1.5)
    own_love_print("2 - Press num 2 [^ <    > 0]", g_windowWidth/18, g_windowHeight/4+75, 0, 0, 0, 0, 1.5)
    own_love_print("^", g_windowWidth/1.39, g_windowHeight/4+95, 0, 0, 0, 3.1415, 1.5) --to put '^' 180deg, I want an arrow pointing down, but ascii only, in future will be an image
    own_love_print("Esc to exit anytime", g_windowWidth/7.5, g_windowHeight/2, 0, 0, 0, 0, 2)
end


function resetGame()
    IN()
    g_meteor.resetMeteorsArray()
    g_gameOver =  false
    g_meteor.resetMeteorScore(#g_players)

    for playerNumber, player in ipairs(g_players) do
        player.img = love.graphics.newImage(player.src ..playerNumber..".png") --need to improve this if possible
        player.w = player.img:getWidth()    -3 --fixing size of png to visual size
        player.h = player.img:getHeight()   -3 --fixing size of png to visual size

        player.imgExploded = love.graphics.newImage(player.srcExploded)
        player.bulletShotImg = love.graphics.newImage(player.srcBulletShot)

        player.sounds.explosion = g_explosionAirplane--love.audio.newSource("sounds/explosion_airplane.mp3", "static")
        player.sounds.oneShotAirplane = g_oneShotAirPlane--love.audio.newSource("sounds/one_shot_airplane.mp3", "static")
        -- will use for different weapons one date
        -- player.sounds.machine_gun_player = love.audio.newSource("sounds/machine_gun_player.mp3", "static")
        -- player.sounds.oneShotPiuAirplane = g_oneShotPiuAirplane--love.audio.newSource("sounds/one_shot_piu_airplane.mp3", "static")

        if #g_players > 1 then
            --spawn playes side by side at botton and center of the window
            if playerNumber == 1 then
                player.x, player.y = (g_windowWidth/2 - player.w - player.w/8), (g_windowHeight - player.h)
            else
                player.x, player.y = (g_windowWidth/2 + player.w/8), (g_windowHeight - player.h)
            end
        else -- spawn player in botton and center of the window
            player.x, player.y = (g_windowWidth/2 - player.w/2), (g_windowHeight - player.h)
        end

        player.moveKeys = player.allMoveKeys[playerNumber]
        player.shotKeys = player.allShotKeys[playerNumber]

        player:resetLife()
    end

    g_meteor.resetMeteorScore(#g_players)
    OUT()
end

---------------- LOVE stuffs ------------------------------------
function love.load()
    math.randomseed(os.time())

    love.window.setMode(g_windowWidth, g_windowHeight, {resizable=false})
    love.window.setTitle("Crazy Aviator")
    
    gameOverSound = love.audio.newSource("sounds/game_over.mp3", "static")
    background = love.graphics.newImage("images/background.png")
    g_meteor.meteorImage = love.graphics.newImage("images/meteor.png")

    g_explosionAirplane   = love.audio.newSource("sounds/explosion_airplane.mp3", "static")
    g_oneShotAirPlane    = love.audio.newSource("sounds/one_shot_airplane.mp3", "static")
    g_oneShotPiuAirplane = love.audio.newSource("sounds/one_shot_piu_airplane.mp3", "static")

    resetGame()
end


function love.keypressed(key)
    --continue game
    if key == 'kpenter' or key == 'return' and g_gamming then
        resetGame()
    end

    -- exit game window
    if key == 'escape' then
        if not g_gamming then
            print("closing game...")
            love.event.quit()
        end

        g_hideMenu = false
        g_gamming = false
        resetGame()
    end

    -- menu keys
    if key == '1' or key == 'kp1' and not g_gamming then
        print("1 player")
        g_hideMenu = true
        g_gamming = true
        if g_players[2] ~= nil then
            table.remove(g_players, 2)
        end
        resetGame()
    elseif key == '2' or key == 'kp2' and not g_gamming then
        print("2 players")
        g_hideMenu = true
        g_gamming = true
        g_players[2] = airplane:new(nil)
        resetGame()
    end

    if g_hideMenu == false then return end

    for _, player in ipairs(g_players) do
        for _, key in ipairs(player.shotKeys) do
            if love.keyboard.isDown(key) then
                player:processKey(tostring(key))
            end
        end
    end
end


function love.update(dt)
    if g_gameOver then
        love.graphics.setColor(1, 1, 1, 0.6)
        return
    end

    for _, player in ipairs(g_players) do
        for _, key in ipairs(player.moveKeys) do
            if love.keyboard.isDown(key) then
                player:processKey(tostring(key))
            end
        end
    end

    g_meteor.createMeteors(math.random(g_windowWidth), -200)
    g_meteor.moveMeteors()
    g_meteor.removeNotVisibleMeteors(g_windowHeight)

    if g_hideMenu == false then return end

    local colision = detectAirplaneMeteorsColision(g_players, g_meteor.meteorsArray)
    for i, player in ipairs(g_players) do
        player.life = player.life - colision[i]
        if player.life <= 0 then --for now, when player1 or player2 dies, it's game over for both
            g_gameOver = true
            player.sounds.explosion:play()
            gameOverSound:play()
        end
        player:move_shots()

    end

    local resultOfScore = detectBulletsMeteorsColision(g_players, g_meteor.meteorsArray)
    for i=1, #g_meteor.meteorScore do
        g_meteor.meteorScore[i] = g_meteor.meteorScore[i] + resultOfScore[i]
    end
end


function love.draw()
    -- order of draw is importante because of 'Z-index'. Eg.: background is behind player1
    love.graphics.draw(background, 0, 0)
    
    for k, meteor in ipairs(g_meteor.meteorsArray) do
        love.graphics.draw(g_meteor.meteorImage, meteor.x, meteor.y, 0--[[meteor.angle--]], meteor.weight)
    end

    gameMenu(g_hideMenu)

    if g_hideMenu == false then return end

    for playerNumber, player in ipairs(g_players) do
        if(g_gameOver) then
            love.graphics.draw(player.imgExploded, player.x, player.y)
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.print("FAIL",              0.60*(g_windowWidth/2), g_windowHeight/4, 0, 5)
            love.graphics.print("ENTER to continue", 0.20*(g_windowWidth/2), g_windowHeight/1.7, 0, 2)
            love.graphics.print("ESC to quit",       0.20*(g_windowWidth/2), g_windowHeight/1.5, 0, 2)
            love.graphics.setColor(1, 1, 1)
            return
        else
            love.graphics.draw(player.img, player.x, player.y)
        end

        for k, shot in ipairs(player.shots) do
            love.graphics.draw(player.bulletShotImg, shot.x, shot.y, 0--[[rotation]], shot.sx, shot.sy)
        end

        local text = "Player"..playerNumber.." LIFE:     ["..player.life.."]"
        local r,g,b,y = 1, 0, 0, 0
        if playerNumber > 1 then r,g,b,y = .1, .4, .4 ,85 end
        own_love_print(text, x, y, r, g, b, rotation, 2)
    end

    for i=1, #g_meteor.meteorScore do
        local text =  "Player"..i.." SCORE: ["..g_meteor.meteorScore[i].."]"
        local r,g,b,y = 1, 0 ,0 , 20
        if i > 1 then r,g,b,y = .1, .4, .4, 105 end
        own_love_print(text, x, y, r, g, b, rotation, 2)
    end
end