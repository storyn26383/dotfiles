local alertStyle = {
  textStyle = {
    paragraphStyle = {
      alignment = 'center'
    }
  }
}

local function bind(from, to, pressed, released)
  local pressedfn = function()
    if pressed ~= nil then pressed() end
    if to ~= nil then hs.eventtap.keyStroke(to.mods or {}, to.key, 0) end
  end
  local releasedfn = released or nil
  local repeatfn = pressedfn

  return hs.hotkey.bind(from.mods or {}, from.key, pressedfn, releasedfn, repeatfn)
end

-- global
-- bind({ key = 'rightctrl' }, { key = 'fn' })
-- bind({ mods = {'cmd'}, key = 'tab' }, { key = 'f13' }):enable()

-- local disableBackspace = bind({ key = 'delete' }, nil, function ()
--   hs.alert.show('BACKSPACE KEY IS FORBIDDEN', alertStyle)
-- end)

-- disable when a specific application is active
local key_bindings = {
  -- bind(
  --   { mods = {'ctrl'}, key = 'h' },
  --   { key = 'delete' },
  --   function () disableBackspace:disable() end,
  --   function () disableBackspace:enable() end
  -- ),
  bind({ mods = {'ctrl'}, key = 'h' }, { key = 'delete' }),
  bind({ mods = {'ctrl'}, key = '[' }, { key = 'escape' }),
  bind({ mods = {'ctrl'}, key = 'p' }, { key = 'up' }),
  bind({ mods = {'ctrl'}, key = 'n' }, { key = 'down' }),
  bind({ mods = {'ctrl'}, key = 'b' }, { key = 'left' }),
  bind({ mods = {'ctrl'}, key = 'f' }, { key = 'right' }),
  bind({ mods = {'ctrl'}, key = 'e' }, { mods = {'cmd'}, key = 'right' }),
  bind({ mods = {'ctrl'}, key = 'a' }, { mods = {'cmd'}, key = 'left' }),
}

hs.application.watcher.new(function (app, event)
  if event == hs.application.watcher.activated then
    local method = 'enable'

    if app == 'Alacritty' or app == 'iTerm2' then
      method = 'disable'
    end

    for _, binding in ipairs(key_bindings) do
      binding[method](binding)
    end
  end
end):start()

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
