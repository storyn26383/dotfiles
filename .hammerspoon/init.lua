-- hs.eventtap.keyStroke(modifiers, character[, delay])
-- hs.hotkey.bind(mods, key, message, pressedfn, releasedfn, repeatfn)

local function bind(from, to, pressedfn, releasedfn)
  local fn = function ()
    if pressedfn ~= nil then pressedfn() end
    if to ~= nil then hs.eventtap.keyStroke(to.mods or {}, to.key, 0) end
  end

  return hs.hotkey.bind(from.mods or {}, from.key, fn, releasedfn, fn)
end

-- global
bind({ key = 'rightctrl' }, { key = 'fn' })

local disableDelete = bind({ key = 'delete' }, nil)
bind(
  { mods = {'ctrl'}, key = 'h' },
  { key = 'delete' },
  function () disableDelete:disable() end,
  function () disableDelete:enable() end
)

-- disable when a specific application is active
local keys = {
  bind({ mods = {'ctrl'}, key = '[' }, { key = 'escape' }),
  bind({ mods = {'ctrl'}, key = 'p' }, { key = 'up' }),
  bind({ mods = {'ctrl'}, key = 'n' }, { key = 'down' }),
  bind({ mods = {'ctrl'}, key = 'b' }, { key = 'left' }),
  bind({ mods = {'ctrl'}, key = 'f' }, { key = 'right' }),
  bind({ mods = {'ctrl'}, key = 'e' }, { mods = {'command'}, key = 'right' }),
  bind({ mods = {'ctrl'}, key = 'a' }, { mods = {'command'}, key = 'left' })
}

local function handleGlobalAppEvent(name, event, app)
  if event == hs.application.watcher.activated then
    local method

    if name == 'iTerm2' or name == 'MacVim' then method = 'disable'
    else method = 'enable'
    end

    for i, key in ipairs(keys) do
      key[method](key)
    end
  end
end

appsWatcher = hs.application.watcher.new(handleGlobalAppEvent)
appsWatcher:start()
