local alertStyle = {
  textStyle = {
    paragraphStyle = {
      alignment = 'center'
    }
  }
}

local excludedBundleIds = {
  ['org.alacritty'] = true,
  ['com.googlecode.iterm2'] = true,
  ['com.microsoft.VSCode'] = true,
}

-- Copy Deeplink action on Raycast's Switch Windows command gives the exact URL
local switchWindowsDeeplink = 'raycast://extensions/raycast/navigation/switch-windows'

local flagMasks = hs.eventtap.event.rawFlagMasks
local noModifier = 0
local leftControl = flagMasks.control | flagMasks.deviceLeftControl
local leftCommand = flagMasks.command | flagMasks.deviceLeftCommand
local leftAlternate = flagMasks.alternate | flagMasks.deviceLeftAlternate
-- Every modifier bit, so a rule only fires when its modifier is the only one held
local modifierMask = flagMasks.shift | flagMasks.control | flagMasks.alternate | flagMasks.command
  | flagMasks.secondaryFn
  | flagMasks.deviceLeftShift | flagMasks.deviceRightShift
  | flagMasks.deviceLeftControl | flagMasks.deviceRightControl
  | flagMasks.deviceLeftAlternate | flagMasks.deviceRightAlternate
  | flagMasks.deviceLeftCommand | flagMasks.deviceRightCommand

local rules = {
  { from = { flags = leftCommand, key = 'tab' }, to = { url = switchWindowsDeeplink } },
  { from = { flags = leftControl, key = '[' }, to = { flags = noModifier, key = 'escape' } },
  { from = { flags = leftControl, key = 'm' }, to = { flags = noModifier, key = 'return' } },
  { from = { flags = leftControl, key = 'h' }, to = { flags = noModifier, key = 'delete' }, skipInExcludedApps = true },
  { from = { flags = leftControl, key = 'p' }, to = { flags = noModifier, key = 'up' }, skipInExcludedApps = true },
  { from = { flags = leftControl, key = 'n' }, to = { flags = noModifier, key = 'down' }, skipInExcludedApps = true },
  { from = { flags = leftControl, key = 'b' }, to = { flags = noModifier, key = 'left' }, skipInExcludedApps = true },
  { from = { flags = leftControl, key = 'f' }, to = { flags = noModifier, key = 'right' }, skipInExcludedApps = true },
  { from = { flags = leftControl, key = 'a' }, to = { flags = leftCommand, key = 'left' }, skipInExcludedApps = true },
  { from = { flags = leftControl, key = 'e' }, to = { flags = leftCommand, key = 'right' }, skipInExcludedApps = true },
  { from = { flags = leftControl, key = 'w' }, to = { flags = leftAlternate, key = 'delete' }, skipInExcludedApps = true },
  { from = { flags = leftControl, key = 'u' }, to = { flags = leftCommand, key = 'delete' }, skipInExcludedApps = true },
}

local rulesByKeyCode = {}
for _, rule in ipairs(rules) do
  rulesByKeyCode[hs.keycodes.map[rule.from.key]] = rule
end

-- Remembered per key so the key-up is remapped even if the modifier is released first
local activeRulesByKeyCode = {}

local keyDownType = hs.eventtap.event.types.keyDown
local keyUpType = hs.eventtap.event.types.keyUp
local remapWatchdogIntervalSeconds = 5

local function isInExcludedApp()
  local app = hs.application.frontmostApplication()
  return app ~= nil and excludedBundleIds[app:bundleID()] == true
end

local swallowEvent = true
local passEvent = false
local autorepeatProperty = hs.eventtap.event.properties.keyboardEventAutorepeat

-- Rewrites the original event so key repeat and key-up stay native; non-modifier bits are kept
local function rewrite(event, rule)
  event:setKeyCode(hs.keycodes.map[rule.to.key])
  event:rawFlags((event:rawFlags() & ~modifierMask) | rule.to.flags)
  return passEvent
end

-- Opens the URL once per press; key repeat and key-up are swallowed so the app sees nothing
local function openUrl(event, rule, isDown)
  if isDown and event:getProperty(autorepeatProperty) == 0 then hs.urlevent.openURL(rule.to.url) end
  return swallowEvent
end

local function apply(event, rule, isDown)
  if rule.to.url ~= nil then return openUrl(event, rule, isDown) end
  return rewrite(event, rule)
end

local function onKeyDown(event)
  local keyCode = event:getKeyCode()
  local rule = rulesByKeyCode[keyCode]
  if rule == nil then return passEvent end
  if (event:rawFlags() & modifierMask) ~= rule.from.flags then return passEvent end
  if rule.skipInExcludedApps and isInExcludedApp() then return passEvent end

  activeRulesByKeyCode[keyCode] = rule
  return apply(event, rule, true)
end

local function onKeyUp(event)
  local keyCode = event:getKeyCode()
  local rule = activeRulesByKeyCode[keyCode]
  if rule == nil then return passEvent end

  activeRulesByKeyCode[keyCode] = nil
  return apply(event, rule, false)
end

local function onKeyEvent(event)
  if event:getType() == keyDownType then return onKeyDown(event) end
  return onKeyUp(event)
end

-- Globals: Hammerspoon garbage-collects unreferenced taps and timers, which silently stops them
keyRemapTap = hs.eventtap.new({ keyDownType, keyUpType }, onKeyEvent):start()

-- macOS disables a tap whose callback times out; turn it back on
keyRemapWatchdog = hs.timer.doEvery(remapWatchdogIntervalSeconds, function ()
  if keyRemapTap:isEnabled() then return end
  keyRemapTap:start()
end)

local showKeyPressHandler = hs.eventtap.new(
  {hs.eventtap.event.types.keyDown},
  function (e)
    local duration = 1
    local flags = e:getFlags()
    local key = hs.keycodes.map[e:getKeyCode()]
    local mods = ''

    if     key == 'return' then key = '⏎'
    elseif key == 'delete' then key = '⌫'
    elseif key == 'escape' then key = '⎋'
    elseif key == 'space'  then key = 'SPC'
    elseif key == 'up'     then key = '↑'
    elseif key == 'down'   then key = '↓'
    elseif key == 'left'   then key = '←'
    elseif key == 'right'  then key = '→'
    end

    if flags.ctrl  then mods = mods .. '^' end
    if flags.shift then mods = mods .. '⇧' end
    if flags.alt   then mods = mods .. '⌥' end
    if flags.cmd   then mods = mods .. '⌘' end

    if (not (flags.shift or flags.cmd or flags.alt or flags.ctrl)) then
      duration = 0.2
    end

    hs.alert.show(mods .. string.upper(key), alertStyle, duration)
  end
)

local showKeyPress = false

hs.hotkey.bind({'cmd', 'shift', 'ctrl'}, 'p', function ()
  showKeyPress = not showKeyPress

  if showKeyPress then
    hs.alert.show('Enable Keypress Show Mode', alertStyle, 1.5)
    showKeyPressHandler:start()
  else
    showKeyPressHandler:stop()
    hs.alert.show('Disable Keypress Show Mode', alertStyle, 1.5)
  end
end)

hs.hotkey.bind({'cmd', 'shift', 'ctrl'}, 'r', function () hs.reload() end)
hs.notify.new({ title = 'Hammerspoon', informativeText = 'Config loaded.' }):send()
