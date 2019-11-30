-- Renderer.lua
--

local json = require('json')

-- Overview
-- 
-- All drawing should be separate(d) from logic
-- This file should provide high level control over the flow of animations
-- The following controls the animation of all the entities in the world
-- syncing them to beats of music
--
--
-- How does it work?
--
-- While doing the logic computations, game objects change their corresponding
-- history objects (or lists) that would afterwards carry information on the
-- order of actions that were done on the game object.
--
-- History objects are used for two purposes:
--      1. syncing animations and figuring out the timings
--      2. game logic (e.g. figuring whether the character has been hurt or not)
--
-- I don't feel like this approach is bad, it is the way that I implemeted it at first
-- that was bad.
--
-- Now the question arises: do I keep history on game objects, or do I in a way centralize that?
--
-- So my idea is: when I am mutating history, I am going to push, through game controller
-- (kinda like a global thing that manages the world events) (maybe leave it a world as it used to be),
-- the updates to the list that has the entire beat's history — all the things that happened during one
-- iteration of the game loop. This way I would keep logic and drawing more separate, which is 
-- the thing I'm trying to achieve here. So in the end the renderer (this thing) is going to use
-- one beat history thing while all other entities in their logic — completely separate ones
--
-- I'm thinking the id that each 

-- This is the list that is going to contain
-- all events of a single beat
local beatHistory = {}

-- an event object is going to look like this
-- {
--      id: "alphanumeric string",
--      phase: the phase during which the event occured, probably a member of an enum,
--      name: index of the event (member of an set of constants),
--      entity: the reference to the entity itself
--          (or just all necessary fields at the moment of this event)
--      entityAfter: the reference to the entity after the event
--
--      NEW:
--      characterState: key   : if the current state and this field are different, 
--                              we got to queue this animation in the current list of animations
--                              and gradually trigger the change somehow
--                      This should be included in entity and entityAfter!!!
-- }

-- TODO: move to game controller
-- the turn phase. Advanced each time some specific event occurs
-- local phase = 0


-- TODO: expose this function
local function registerEvent(event)
    table.add(beatHistory, event)
end


-- We will probably need something that would store all sprites and stuff
-- As I want to separate logic off of rendering, all sprites should obviously
-- be here. But then we have a problem: what do we do if an entity is willing
-- to change it's sprite? I think we should just have a function that does that
--
-- I'm thinking a good idea would be to store all sprites of an object as a table
-- {
--      the first character state
--      "state 1":
--      {
--          the default animation
--          "idle": { a list of images },
--          attack sequence
--          "attack": { blah blah }, ...
--      },
--      "state 2": ...
-- }
-- This is simple, while also being quite manageable
--
-- The next question is how do I manage animations of changing the state?
-- {
--      the first character state
--      "state 1":
--      {
--          the default animation
--          "idle": { a list of images },
--          attack sequence
--          "attack": { blah blah },
--#         "shifts": 
--#         {
--#             2: {...}, ...
--#         }
--      },
--      "state 2": ...
-- }
-- I think thing would do ok. I'm going to stick with this
--
-- So next up, we're going to put these sprite packs into a table that
-- associates real game objects to it via id's
-- {
--      "abc": Player,
--      "6yh": Skeleton, ...
-- }
-- which is going to be unique (both id and the animation table) for each
-- game object/entity/creature/whatever currently alive (or dying) in game
--
-- Now what about loading the necessary files into memory?
-- Let's do it this way: each game object is going to be associated
-- an id: a link to the sprites of a certain type, i.e. for each
-- species of creatures there is an associated configuration that
-- specifies which images and what sprite scheme it is going to use.
-- I think it would be a good idea for this to be of the format described above
-- with the sprite animation sequences
--
-- The format which we store the images in
-- There are 2 possibilities on this:
--      1. a separate file for each event animation, 
--           change state animation, with separate folders for each
--      2. shove everything in a single file
-- I bet the first one is much more manageable.
-- see sprite.json for an example config
--

-- So, I'm thinking, each and every one of them should have all the possible
-- events that they could use. If the sprites they use are the same, let's do
-- so that they will have to write the fallback key after the corresponding one
local eventNames = {
    idle = "idle",
    attack = "attack",
    dying = "dying",
    -- ...
}

local allEntityTypes = {}
-- this will contain the loaded json files
local allEntityConfigs = {}

local function registerEntityType(entityType, relativeConfigPath) 
    table.insert(allEntityTypes, entityType)
    local id = entityType.id
    local configPath = system.pathForFile(relativeConfigPath, system.ResourceDirectory )
    local config = json.decodeFile(configPath)
    -- I'm probably going to modify it to include music assets too,
    -- which in theory should be handled by this file as well
    allEntityConfigs[id] = config
end

local spriteLists = {}

local function load(config)
    local spriteList = {}

    for stateName,stateConfig in pairs(config) do

        local state = {}
        
        for _,eventName in pairs(eventNames) do

            local eventConfig = stateConfig[eventName]

            assert(eventConfig ~= nil)

            if type(eventConfig) == 'string' then
                state[eventName] = eventConfig
            else            
                local fullPath = system.pathForFile(eventConfig.path, system.ResourceDirectory)
                state[eventName] = graphics.newImageSheet(fullPath, eventConfig.options)
            end
        end
        
        spriteList[stateName] = state
    end
    return spriteList
end

local function loadAll()
    for id,config in pairs(allEntityConfigs) do
        local loaded = load(id, config)
        spriteLists[id] = loaded
    end
end


-- this is the list of all currently existing entities
local entities = {}

-- current animation states of all objects
local animationProperties = {}

local scale = 1 / UNIT
local defaultWidth = 1
local defaultHeight = 1

local function createSprites(config)
    local instanceSprites = {}
    
    for stateName,stateConfig in pairs(config) do

        local state = {}
        
        for eventName,eventConfig in pairs(stateConfig) do

            assert(eventConfig ~= nil)
            assert(spriteLists[stateName][eventName] ~= nil)

            local sheet = spriteLists[stateName][eventName]

            if type(sheet) == 'string' then
                state[eventName] = sheet
            else
                for i = 1, eventConfig.options.numFrames do            
                    local image = display.newImageRect(sheet, i, defaultWidth, defaultHeight)
                    state[eventName][i] = image
                    image.alpha = 0
                end
            end
        end
        
        instanceSprites[stateName] = state
    end
    return instanceSprites
end


local function registerEntity(typeId) 
    -- TODO: generate unique id
    local id = 1
    
    -- get the relevant loaded config
    local config = allEntityConfigs[typeId]

    -- initialize all sprites and assets
    local spriteList = createSprites(config)

    local properties = {
        stateQueue = {},
        currentState = 1
    }

    animationProperties[id] = properties

end

-- 
-- local function 

-- assume this indicates the total number of distinct 
-- turn phases that wlways have to be accounted for
local numPhases = 5


-- TODO:
-- calculate the time left until the beat is over
-- plus a little extra; to do all animations in either case 
local function getTimeLeft()
    return 250  
end


-- this function creates new animation properties object.
-- It goes through all events that occured during this beat and queues them 
-- in a propeties object.
local function createAnimationProperties(oldProperties, history)
    local newPropeties = table.deepClone(oldProperties)
    local currentPhase = history[0].phase
    local timeLeft = getTimeLeft()

    for i = 1, #history do
        local id = history[i].id
        local phase = history[i].phase
        local entity = history[i].entity
        local entityAfter = history[i].entityAfter

        if phase ~= currentPhase then
            
        end


        -- The properties object is going to be as follows:
        -- {
        --      TODO:     
        -- }

    end
end


display.setDefault('magTextureFilter', 'nearest')
display.setDefault('minTextureFilter', 'nearest')