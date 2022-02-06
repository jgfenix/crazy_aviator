-- using Lua Löve 11.4 64b
-- using Lua 5.3.6 win32

----------------------------------------------------------------
-- globals stuffs
AIRPLANE_VELOCITY = 3
SHOT_VELOCITY=5

meteorsArray = {}
MAX_OF_METEOR_ARRAY = 8
METEOR_VELOCITY = 1
METEOR_SCORE = 0


GAME_OVER = false
----------------------------------------------------------------
airplane = {
    src = "images/airplane.png",
    src_exploded = "images/explosao.png",
    img_exploded = nil,
    bullet_shot_img = nil,

    w = 0, h = 0,
    x = 0,  y = 0,

    life = 3,

    bullet_shot="images/bullet_shot.png",

    shots = {},
    sounds = {},

    -- will change detected keys when implement 2 airplanes on game
    move = function()
        -- using 'if' instead of 'elsif' whe can move airplane on diagonals
        if love.keyboard.isDown('w', 'up') then
            if airplane.h / 3 + (airplane.y - AIRPLANE_VELOCITY) > 0 then
                airplane.y = airplane.y - AIRPLANE_VELOCITY
            end
        end
        if love.keyboard.isDown('s', 'down') then
            if airplane.h + (airplane.y + AIRPLANE_VELOCITY) < window_height then
                airplane.y = airplane.y + AIRPLANE_VELOCITY
            end
        end
        if love.keyboard.isDown('a', 'left') then
            -- middle of airplane on screen
            if (airplane.x - AIRPLANE_VELOCITY + airplane.w/2) > 0 then
                airplane.x = airplane.x - AIRPLANE_VELOCITY
            end
        end
        if love.keyboard.isDown('d', 'right') then
            -- middle of airplane on screen
            if airplane.w/2 + (airplane.x + AIRPLANE_VELOCITY) < window_width then
                airplane.x = airplane.x + AIRPLANE_VELOCITY
            end
        end
    end
}

function do_shot()
    -- maximum of 5 shots at time
    if #airplane.shots > 5 then return end

    local shot = {
        x = airplane.x+(airplane.w/2)-5,
        y = airplane.y-airplane.h, --10
        w = 15,
        h = 40
    }

    table.insert(airplane.shots, shot)

    -- airplane.sounds.one_shot_piu_airplane:play()
    airplane.sounds.one_shot_airplane:play()
end

function move_shots()
    for i=#airplane.shots, 1, -1 do
        if airplane.shots[i].y > 0 then
            airplane.shots[i].y = airplane.shots[i].y - SHOT_VELOCITY --shot go up
        else
            table.remove(airplane.shots, i)
        end
    end
end
----------------------------------------------------------------
function createMeteors(_x, _y)
    -- not spawn more meteors if all of MAX_OF_METEOR_ARRAY are still visible 
    if #meteorsArray > MAX_OF_METEOR_ARRAY then
        return
    end
    local l_weight = math.random(0.5, 1.5)

    meteor = {
        weight = l_weight, --= math.random(0.5, 1.5), --creating meteors with different sizes
        w = l_weight * meteorImage:getWidth()   -3, --fixing png size transparency
        h = l_weight * meteorImage:getHeight()  -3, --fixing png size transparency
        x = _x,  y = _y,
        angle = math.random(-0.785398, 0.785398) -- -45º to +45º to rotate meteor image and define (x,y) direction

    }
    table.insert(meteorsArray, meteor)
end

function moveMeteors()
    for k,localMeteor in pairs(meteorsArray) do
        localMeteor.y = localMeteor.y + METEOR_VELOCITY + 1/localMeteor.weight
        if localMeteor.angle >= 0 then
            localMeteor.x = localMeteor.x - METEOR_VELOCITY/2 -- localMeteor.weight --localMeteor.angle
        else
            localMeteor.x = localMeteor.x + METEOR_VELOCITY/2 -- localMeteor.weight --localMeteor.angle
        end
    end
end

function removeNotVisibleMeteors()
    for i=#meteorsArray, 1, -1 do
        if meteorsArray[i].y > window_height then
            table.remove(meteorsArray, i)
        end 
    end
end
----------------------------------------------------------------
function detectAirplaneMeteorsColision()
    local collision = 0 --detect just one collision
    a = airplane
    for i=#meteorsArray, 1, -1 do
        m = meteorsArray[i]

        ret =   m.x < a.x + a.w and
                a.x < m.x + m.w and
                a.y < m.y + m.h and
                m.y < a.y + a.h

        if ret then
            table.remove(meteorsArray, i)
            collision =  collision + 1
        end
    end
    return collision
end
----------------------------------------------------------------
function detectBulletsMeteorsColision()
    local crash_amount = 0
    for k=#airplane.shots, 1, -1 do
        s=airplane.shots[k]
        for i=#meteorsArray, 1, -1 do
            m = meteorsArray[i]

            ret =   m.x < s.x + s.w and
                    s.x < m.x + m.w and
                    s.y < m.y + m.h and
                    m.y < s.y + s.h

            if ret then
                table.remove(meteorsArray, i)
                table.remove(airplane.shots, k) --at first will remove shot to not crash with others meteors, future future is to powerfull weapon crash others meteors
                crash_amount = crash_amount + 1
            end
        end
    end
    return crash_amount
end

---------------- LOVE stuffs ------------------------------------
function love.keypressed(key)
    -- exit game window
    if key == 'escape' then
        print("closing game...")
        -- love.window.close()
        love.event.quit()
    elseif key == 'space' then
        do_shot()
    end
end

function love.load()
    math.randomseed(os.time())

    window_width, window_height = 320, 480
    love.window.setMode(window_width, window_height, {resizable=false})
    love.window.setTitle("Crazy Aviator")
    
    airplane.img = love.graphics.newImage(airplane.src)
    airplane.w = airplane.img:getWidth()    -3 --fixing size of png to visual size
    airplane.h = airplane.img:getHeight()   -3 --fixing size of png to visual size

    airplane.img_exploded = love.graphics.newImage(airplane.src_exploded)
    airplane.bullet_shot_img = love.graphics.newImage(airplane.bullet_shot)

    airplane.sounds.explosion = love.audio.newSource("sounds/explosion_airplane.mp3", "static")
    -- will use for different weapons
    -- airplane.sounds.machine_gun_airplane = love.audio.newSource("sounds/machine_gun_airplane.mp3", "static")
    airplane.sounds.one_shot_airplane = love.audio.newSource("sounds/one_shot_airplane.mp3", "static")
    airplane.sounds.one_shot_piu_airplane = love.audio.newSource("sounds/one_shot_piu_airplane.mp3", "static")

    game_over_sound = love.audio.newSource("sounds/game_over.mp3", "static")

    -- spawn airplane in botton and center of the window
    airplane.x, airplane.y = (window_width/2 - airplane.w/2), (window_height - airplane.h)

    background = love.graphics.newImage("images/background.png")
    
    meteorImage = love.graphics.newImage("images/meteor.png")
end

function love.update(dt)

    if love.keyboard.isDown('kpenter',  'return') then
        meteorsArray = {}
        GAME_OVER =  false
        airplane.life = 3
        METEOR_SCORE = 0
    end

    if GAME_OVER then
        love.graphics.setColor(1, 1, 1, 0.6)
        return
    end

    if love.keyboard.isDown('w', 'up', 's', 'down', 'a', 'left', 'd', 'right', 'space') then
        airplane.move()
    end

    createMeteors(math.random(window_width), -200)
    moveMeteors()
    removeNotVisibleMeteors()

    colision = detectAirplaneMeteorsColision()
    airplane.life = airplane.life - colision

    move_shots()
    METEOR_SCORE = METEOR_SCORE + detectBulletsMeteorsColision()
    
    if airplane.life <= 0 then
        GAME_OVER = true
        airplane.sounds.explosion:play()
        game_over_sound:play()
    end
end


function love.draw()
    -- order of draw is importante because of 'Z-index'. Eg.: background is behind airplane
    love.graphics.draw(background, 0, 0)

    if(GAME_OVER) then
        love.graphics.draw(airplane.img_exploded, airplane.x, airplane.y)
    else
        love.graphics.draw(airplane.img, airplane.x, airplane.y)
    end
    
    for k, meteor in pairs(meteorsArray) do
        love.graphics.draw(meteorImage, meteor.x, meteor.y, 0--[[meteor.angle--]], meteor.weight)
    end

    for k, shot in pairs(airplane.shots) do
        love.graphics.draw(airplane.bullet_shot_img, shot.x, shot.y)
    end

    if GAME_OVER then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.print("FAIL",              0.60*(window_width/2), window_height/4, 0, 5)
        love.graphics.print("ENTER to continue", 0.20*(window_width/2), window_height/1.7, 0, 2)
        love.graphics.print("ESC to quit",       0.20*(window_width/2), window_height/1.5, 0, 2)
        love.graphics.setColor(1, 1, 1)
        return
    end

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("LIFE:     ["..airplane.life.."]", 0, 0, 0, 2)
    love.graphics.setColor(1, 1, 1)

    love.graphics.setColor(.5, .5, 0)
    love.graphics.print("SCORE: ["..METEOR_SCORE.."]", 0, 25, 0, 2)
    love.graphics.setColor(1, 1, 1)
end