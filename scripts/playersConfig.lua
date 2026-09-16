local groundName = 'ground'
local player1name = 'boyfriend'
local player2name = 'dad'

local canAttackP1 = true
local canAttackP2 = true
local i = 0
local j = 0

local p1KeyBinds = {
    ['attack'] = 'SHIFT',
    ['moveLeft'] = 'LEFT',
    ['moveRight'] = 'RIGHT',
    ['jump'] = 'UP'
}

local p2KeyBinds = {
    ['attack'] = 'C',
    ['moveLeft'] = 'A',
    ['moveRight'] = 'D',
    ['jump'] = 'W'
}


-- =========================================
-- COLLISION
-- =========================================

function checkCollision(a, b)
    local ax = getProperty(a .. '.x')
    local ay = getProperty(a .. '.y')
    local aw = getProperty(a .. '.width')
    local ah = getProperty(a .. '.height')

    local bx = getProperty(b .. '.x')
    local by = getProperty(b .. '.y')
    local bw = getProperty(b .. '.width')
    local bh = getProperty(b .. '.height')

    return ax < bx + bw
       and ax + aw > bx
       and ay < by + bh
       and ay + ah > by
end


-- =========================================
-- JUMP CONFIG
-- =========================================

local jumpHeight = 200
local timeToPeak = 0.2

local jumpVelocity = -(2 * jumpHeight / timeToPeak)
local gravityP1 = (2 * jumpHeight) / (timeToPeak * timeToPeak)
local gravityP2 = (2 * jumpHeight) / (timeToPeak * timeToPeak)

local groundedP1 = false
local groundedP2 = false


local function jumpFc(a)
    if a == player1name then
        if groundedP1 then
            groundedP1 = false

            setProperty(a .. '.velocity.y', jumpVelocity)
        end
    

    elseif a == player2name then
        if groundedP2 then
            groundedP2 = false
            setProperty(player .. '.velocity.y', jumpVelocity)
        end
    end
end


-- =========================================
-- CREATE
-- =========================================

function onCreate()

    -- Ground
    makeLuaSprite('ground', '', 100, 850)
    makeGraphic('ground', 2000, 100, '0FF000')

    setObjectCamera('ground', 'camGame')
    addLuaSprite('ground', true)


    -- Player 1 hitbox
    makeLuaSprite('p1Hitbox', '', 0, 0)
    makeGraphic('p1Hitbox', 420, getProperty('boyfriend.height'), '000000')

    setObjectCamera('p1Hitbox', 'camGame')
    addLuaSprite('p1Hitbox', false)
end


function onCreatePost()
    setProperty('boyfriend.y', 200)
    setProperty('gf.alpha', 0)
end


-- =========================================
-- UPDATE
-- =========================================

function onUpdate()
    setProperty('p1Hitbox.x', getProperty('boyfriend.x'))
    setProperty('p1Hitbox.y', getProperty('boyfriend.y'))
end


function onUpdatePost(elapsed)

    -- =====================================
    -- PLAYER 1
    -- =====================================

    -- Movement
    if keyboardPressed(p1KeyBinds['moveLeft']) then
        curPos = setProperty(
            'boyfriend.x',
            getProperty('boyfriend.x') - 1000 * elapsed
        )
    end

    if keyboardPressed(p1KeyBinds['moveRight']) then
        curPos = setProperty(
            'boyfriend.x',
            getProperty('boyfriend.x') + 1000 * elapsed
        )
    end


    -- Jump
    if keyboardJustPressed(p1KeyBinds['jump']) then
        jumpFc(player1name)
    end

    setProperty('boyfriend.x', curPos)


    -- =====================================
    -- PLAYER 2
    -- =====================================

    if keyboardPressed(p2KeyBinds['moveLeft']) then
        setProperty(
            'dad.x',
            getProperty('dad.x') - 1000 * elapsed
        )
    end

    if keyboardPressed(p2KeyBinds['moveRight']) then
        setProperty(
            'dad.x',
            getProperty('dad.x') + 1000 * elapsed
        )
    end


    if keyboardJustPressed(p2KeyBinds['jump']) then
        jumpFc(player2name)
    end
    


    -- =====================================
    -- GRAVITY / GROUND
    -- =====================================

    if not groundedP1 then
        setProperty(
            'boyfriend.velocity.y',
            getProperty('boyfriend.velocity.y') + gravityP1 * elapsed
        )
    end


    local velocityY = getProperty('boyfriend.velocity.y')

    if velocityY >= 0 and checkCollision(player1name, groundName) then

        local groundY = getProperty('ground.y')
        local playerHeight = getProperty('boyfriend.height')

        setProperty(
            'boyfriend.y',
            groundY - playerHeight
        )

        setProperty('boyfriend.velocity.y', 0)

        groundedP1 = true
    end

    -------------------------------------------------------

    if not groundedP2 then
        setProperty(
            'dad.velocity.y',
            getProperty('dad.velocity.y') + gravityP2 * elapsed
        )
    end


    local velocityYP2 = getProperty('dad.velocity.y')

    if velocityYP2 >= 0 and checkCollision(player2name, groundName) then

        local groundY = getProperty('ground.y')
        local playerHeightP2 = getProperty('dad.height')

        setProperty(
            'dad.y',
            groundY - playerHeightP2
        )

        setProperty('dad.velocity.y', 0)

        groundedP2 = true
    end


    -- =====================================
    -- ATTACK
    -- =====================================

    --[[
    if getProperty('boyfriend.animation.curAnim.name') == 'attack' then
        debugPrint(
            'X: ' .. getProperty('boyfriend.x') ..
            ' | Y: ' .. getProperty('boyfriend.y') ..
            ' | Frame: ' .. getProperty('boyfriend.animation.curAnim.curFrame')
        )
    end
    ]]


    if keyboardJustPressed(p1KeyBinds['attack']) then

        makeLuaSprite(
            'shot' .. i,
            '',
            getProperty('boyfriend.x'),
            getProperty('boyfriend.y') + 60
        )

        makeGraphic('shot' .. i, 400, 100, '000000')

        setObjectCamera('shot' .. i, 'camGame')
        setProperty('shot' .. i .. '.alpha', 0.5)

        addLuaSprite('shot' .. i, false)

        playAnim('boyfriend', 'attack', false)
        setProperty('boyfriend.specialAnim', true)

        gravityP1 = 0
        setProperty('boyfriend.velocity.y', 0)

        doTweenX(
            'shot' .. i .. 'tween',
            'shot' .. i,
            getProperty('shot' .. i .. '.x') - 1100,
            0.2,
            'sineInOut'
        )

        runTimer('shotBack', 0.2)

        debugPrint(i)
    end
end


-- =========================================
-- TIMERS
-- =========================================

function onTimerCompleted(tag)

    if tag == 'nextAnim' then
        playAnim('boyfriend', 'attack', true)
    end


    if tag == 'shotBack' then

        doTweenX(
            'shotBack',
            'shot' .. i,
            getProperty('shot' .. i .. '.x') + 1100,
            0.3,
            'sineInOut'
        )

        runTimer('removeShot', 0.3)
    end


    if tag == 'removeShot' then

        gravityP1 = (2 * jumpHeight) / (timeToPeak * timeToPeak)

        removeLuaSprite('shot' .. i)

        i = i + 1
    end
end