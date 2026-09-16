function onCreatePost()
    setProperty('healthBar.visible', false)
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)
    setProperty('timeBar.visible', false)
    setProperty('timeTxt.visible', false)
    setProperty('scoreTxt.visible', false)
    setProperty('botplayTxt.visible', false)

    for i = 0,7 do
        setPropertyFromGroup('strumLineNotes', i, 'visible', false)
        setPropertyFromGroup('strumLineNotes', i, 'x', 9999)
    end

    
local function jumpFunction(a)
    if not grounded then
        setProperty('boyfriend.velocity.y',
            getProperty('boyfriend.velocity.y') + gravity * elapsed)
    end

    
    if grounded and keyboardJustPressed('SPACE') then
        grounded = false

        setProperty('boyfriend.velocity.y', jumpVelocity)
    end
end

local jumpHeight = 100
local timeToPeak = 0.2

local jumpVelocity = -(2 * jumpHeight / timeToPeak)
local gravity = (2 * jumpHeight) / (timeToPeak * timeToPeak)

local grounded = true

    
end