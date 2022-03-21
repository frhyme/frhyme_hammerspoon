--[[
DEVELOPED
2022.03.19 - sng_hn.lee - 연속 키 입력시 키 입력 빠르게 되도록 변환
2022.03.19 - sng_hn.lee - ctrl + hjk 누르고 있으면 계속 눌러지도록 변환 필요: repeatFn
2022.03.19 - sng_hn.lee - ctrl 로 한영 변환
2022.03.20 - sng_hn.lee - escape 눌렀을 때 영어로 전환되도록 하는 함수 변경
2022.03.20 - sng_hn.lee - karabiner에서는 ctrl + shift hjkl 을 통해 block지정이 되는데, hammerspoon 에서는 안됨.
-------------
NOT DEVELOPED YET
2022.03.19 - sng_hn.lee - karabiner에서는 기본적으로 FN + 4 -> go launchpad 등이 서포트되는데, hammerspoon 에서는 안됨.
2022.03.20 - sng_hn.lee - ctrl을 누르면 항상 한영변환이 되는데, ctrl과 다른 키를 함께 눌렀을 때는 한영 변환이 되지 않도록 변경. 즉 단독으로 ctrl 키가 눌렸을 때만 변경되도록
2022.03.20 - sng_hn.lee - 키보드로 마우스 움직이고 클릭할 수 있도록 세팅하려면?
-------------
--]]

-- 2021.12.18 - esc 를 누르면 영어로 자동 전환되도록 변경함.
-- 얘는 더이상 사용되지 않으므로 제외해도 될듯.
--[[
local input_english = "com.apple.keylayout.ABC"
local input_korean = "com.apple.inputmethod.Korean.2SetKorean"

function change_input_english ()
  if (hs.keycodes.currentSourceID() == input_korean) then
    hs.keycodes.currentSourceID(input_english)
  end
  -- escape에 매핑된 아이를 비활성화한다.
  hs.hotkey.disableAll({}, "escape")
  -- 다른 키와 mapping 되지 않은 pure한 esc를 눌러주고.
  hs.eventtap.keyStroke({}, "escape")
  -- 다시 escape에 function을 mapping 해준다.
  hs.hotkey.bind({}, "escape", change_input_english)
end

hs.hotkey.bind({}, "escape", change_input_english)
--]]
------------------------------------------------------------------------------------
-- 2022.03.21 - sng_hn.lee - hammerspoon reload by shortcut
print('-----------------------------------------------------')
print('-- Hammerspoon console Start')
hs.hotkey.bind(
  {'option', 'cmd'}, 
  'r', 
  function() 
    hs.reload() 
  end
)
------------------------------------------------------------------------------------
-- 2022.03.20 - sng_hn.lee - ctrl + shift + hjkl => block
-- function을 만들어서, 아래 간소화할 것.
-- https://www.hammerspoon.org/docs/hs.eventtap.event.html#newKeyEvent
function stroke_shift_arrow(arrow_key) 
  return function ()
    local event = require("hs.eventtap").event
    event.newKeyEvent({'shift'}, arrow_key, true):post()
    event.newKeyEvent({'shift'}, arrow_key, false):post()
  end 
end
hs.hotkey.bind({"ctrl", "shift"}, "H", 
  stroke_shift_arrow('left'),
  function () end, 
  stroke_shift_arrow('left')
)
hs.hotkey.bind({"ctrl", "shift"}, "J", 
  stroke_shift_arrow('down'),
  function () end, 
  stroke_shift_arrow('down')
)
hs.hotkey.bind({"ctrl", "shift"}, "K", 
  stroke_shift_arrow('up'),
  function () end, 
  stroke_shift_arrow('up')
)
hs.hotkey.bind({"ctrl", "shift"}, "L", 
  stroke_shift_arrow('right'),
  function () end, 
  stroke_shift_arrow('right')
)
------------------------------------------------------------------------------------
-- 2022.03.19 - sng_hn.lee - Arrow keys
-- hs.hotkey.bind(mods, key, [message,] pressedfn, releasedfn, repeatfn)
-- 누르고 있는 경우를 고려하기 위해서는 repeatfn 이 정의되어야 함.
function stroke_arrow(arrow_key) 
  -- hs.eventtap.keyStroke()의 경우 중간에 timer.usleep()이
  -- 포함되어 있어, 연속 입력이 어려우므로, 다음처럼 처리하였다.
  local event = require("hs.eventtap").event
  event.newKeyEvent({}, arrow_key, true):post()
  event.newKeyEvent({}, arrow_key, false):post()
end

hs.hotkey.bind({"ctrl"}, "H", 
  function () stroke_arrow('left') end,
  function () end, 
  function () stroke_arrow('left') end
)
hs.hotkey.bind({"ctrl"}, "J", 
  function () stroke_arrow('down') end,
  function () end, 
  function () stroke_arrow('down') end
)
hs.hotkey.bind({"ctrl"}, "K", 
  function () stroke_arrow('up') end,
  function () end, 
  function () stroke_arrow('up') end
)
hs.hotkey.bind({"ctrl"}, "L", 
  function () stroke_arrow('right') end,
  function () end, 
  function () stroke_arrow('right') end
)
------------------------------------------------------------------------------------
-- 2022.03.20 - sng_hn.lee - 대충 엇비슷하게 만든것 같기는 한데...흠.
-- 이건 일종의 리스너륾 만든거임. 키가 입력되면 걔가 특정 키인지 확인하고, 해당되는 행위를 수행하도록 함.
-- 다만 왜 아래가 실행되는지에 대해서는 명쾌하게 설명이 안됨.
-- https://leedo1982.github.io/wiki/ESC_CTRL_CAPSLOCK/
-- https://www.hammerspoon.org/docs/hs.eventtap.event.html#types
-- hs.eventtap.event.types.keyDown: modifier key가 아닌 다른 일반 key에 down이 발생했을 때
escape_keyevent = hs.eventtap.new (
  {hs.eventtap.event.types.keyDown},
  function (event)
    local flags = event:getFlags()
    local keycode = hs.keycodes.map[event:getKeyCode()]

    if (keycode == 'escape') then 
      -- print("This is escape")
      local input_korean = "com.apple.inputmethod.Korean.2SetKorean"
      local input_english = "com.apple.keylayout.ABC"

      local input_source = hs.keycodes.currentSourceID()

      if (input_source ~= input_english) then
        hs.keycodes.currentSourceID(input_english)
      end 
    end 
  end
)
escape_keyevent:start()
------------------------------------------------------------------------------------
-- 2022.03.20 - sng_hn.lee - test
-- hs.eventtap.event.types.flagsChanged: modifier key event 가 발생했을 때.
-- ctrl hjkl 에서도 한영변환이 발생하는데, 한영변환 발생하지 않도록 하려면?
control_keyevent = hs.eventtap.new (
  {hs.eventtap.event.types.flagsChanged},
  function (event)
    local flags = event:getFlags()
    local keycode = hs.keycodes.map[event:getKeyCode()]

    if (flags.ctrl == true) then
      --print("This is ctrl")
      local input_korean = "com.apple.inputmethod.Korean.2SetKorean"
      local input_english = "com.apple.keylayout.ABC"

      local input_source = hs.keycodes.currentSourceID()

      if (input_source == input_english) then
        hs.keycodes.currentSourceID(input_korean)
      elseif (input_source == input_korean) then
        hs.keycodes.currentSourceID(input_english)
      else 
      end
    end
  end
)
control_keyevent:start()
------------------------------------------------------------------------------------
-- End of the Code
hs.alert.show('Hammerspoon Reloaded Completed!')
------------------------------------------------------------------------------------
--[[
EXAMPLES

-- 2022.03.19 - sng_hn.lee - Test. 
k = hs.hotkey.modal.new('cmd-shift', 'd')
function k:entered() hs.alert'Entered mode' end
function k:exited()  hs.alert'Exited mode'  end
k:bind('', 'escape', function() k:exit() end)
k:bind('', 'J', 'Pressed J',function() print'let the record show that J was pressed' end)

-- 2022.03.19 - Alert log  test
hs.hotkey.bind({"ctrl", "shift"}, "r", function ()
  hs.alert.show("aaaa")
end)
--]]
