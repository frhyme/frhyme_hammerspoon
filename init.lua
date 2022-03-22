--[[
IMPLEMENTED
2022.03.19 - sng_hn.lee - 연속 키 입력시 키 입력 빠르게 되도록 변환
2022.03.19 - sng_hn.lee - ctrl + hjk 누르고 있으면 계속 눌러지도록 변환 필요: repeatFn
2022.03.19 - sng_hn.lee - ctrl 로 한영 변환
2022.03.20 - sng_hn.lee - escape 눌렀을 때 영어로 전환되도록 하는 함수 변경
2022.03.20 - sng_hn.lee - karabiner에서는 ctrl + shift hjkl 을 통해 block지정이 되는데, hammerspoon 에서는 안됨.
2022.03.21 - sng_hn.lee - ctrl + cmd + hjkl
2022.03.20 - sng_hn.lee - ctrl을 사용한 복합키를 누르면 항상 한영 변환이 한번 더 일어나도록 처리하여, 입력 소스가 변경되지 않도록 처리함.
-------------
NOT IMPLEMENTED YET
2022.03.19 - sng_hn.lee - karabiner에서는 기본적으로 FN + 4 -> go launchpad 등이 서포트되는데, hammerspoon 에서는 안됨.
2022.03.20 - sng_hn.lee - 키보드로 마우스 움직이고 클릭할 수 있도록 세팅하려면?
2022.03.21 - sng_hn.lee - Caps Lock key 생성 필요함.
-------------
--]]
------------------------------------------------------------------------------------
-- 2022.03.21 - sng_hn.lee - hammerspoon reload by shortcut
print('-----------------------------------------------------')
print('-- Hammerspoon console Start')
function refresh_hammerspoon() 
  hs.hotkey.bind(
    {'option', 'cmd'}, 
    'r', 
    function() 
      hs.reload() 
    end
  )
end 
------------------------------------------------------------------------------------
local function change_kor_en_input () 
  -- 2022.03.22 - sng_hn.lee - 한영전환 함수
  --print("This is ctrl")
  local input_korean = "com.apple.inputmethod.Korean.2SetKorean"
  local input_english = "com.apple.keylayout.ABC"
  local input_source = hs.keycodes.currentSourceID()

  if (hs.keycodes.currentSourceID() == input_english) then
    hs.keycodes.currentSourceID(input_korean)
  elseif (input_source == input_korean) then
    hs.keycodes.currentSourceID(input_english)
  else 
  end
end 
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- 2022.03.20 - sng_hn.lee - ctrl + cmd + shift + hjkl => block
function stroke_cmd_shift_arrow(arrow_key)
  return function ()
    change_kor_en_input()

    local event = require("hs.eventtap").event
    event.newKeyEvent({'shift', 'cmd'}, arrow_key, true):post()
    event.newKeyEvent({'shift', 'cmd'}, arrow_key, false):post()
  end 
end 
------------------------------------------------------------------------------------
-- 2022.03.21 - sng_hn.lee - ctrl + cmd + hjkl => go top, head, tail, bottom 
function stroke_cmd_arrow(arrow_key) 
  return function ()
    change_kor_en_input()
    
    local event = require("hs.eventtap").event
    event.newKeyEvent({'ctrl', 'cmd'}, arrow_key, true):post()
    event.newKeyEvent({'ctrl', 'cmd'}, arrow_key, false):post()
  end 
end
------------------------------------------------------------------------------------
-- 2022.03.20 - sng_hn.lee - ctrl + shift + hjkl => block
-- https://www.hammerspoon.org/docs/hs.eventtap.event.html#newKeyEvent
function stroke_shift_arrow(arrow_key) 
  return function ()
    change_kor_en_input()

    local event = require("hs.eventtap").event
    event.newKeyEvent({'shift'}, arrow_key, true):post()
    event.newKeyEvent({'shift'}, arrow_key, false):post()
  end 
end
------------------------------------------------------------------------------------
-- 2022.03.19 - sng_hn.lee - Arrow keys
-- hs.hotkey.bind(mods, key, [message,] pressedfn, releasedfn, repeatfn)
-- 누르고 있는 경우를 고려하기 위해서는 repeatfn 이 정의되어야 함.
function stroke_arrow(arrow_key) 
  -- hs.eventtap.keyStroke()의 경우 중간에 timer.usleep()이
  -- 포함되어 있어, 연속 입력이 어려우므로, 다음처럼 처리하였다.
  return function () 
    change_kor_en_input()

    local event = require("hs.eventtap").event
    event.newKeyEvent({}, arrow_key, true):post()
    event.newKeyEvent({}, arrow_key, false):post()
  end
end

function all_arrow_key_binding ()
  local arrow_table = {
    H='left', J='down', K='up', L='right'
  }

  for k, v in pairs(arrow_table) do
    hs.hotkey.bind({"ctrl", "cmd", 'shift'}, k, 
      stroke_cmd_shift_arrow(v), 
      function () end, 
      stroke_cmd_shift_arrow(v)
    )
    hs.hotkey.bind({"ctrl", "cmd"}, k, 
      stroke_cmd_arrow(v),
      function () end, 
      stroke_cmd_arrow(v)
    )
    hs.hotkey.bind({"ctrl", "shift"}, k, 
      stroke_shift_arrow(v),
      function () end, 
      stroke_shift_arrow(v)
    )
    hs.hotkey.bind({"ctrl"}, k, 
      stroke_arrow(v), 
      function () end, 
      stroke_arrow(v)
    )
  end 
end

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- 2022.03.20 - sng_hn.lee - 대충 엇비슷하게 만든것 같기는 한데...흠.
-- 이건 일종의 리스너륾 만든거임. 키가 입력되면 걔가 특정 키인지 확인하고, 해당되는 행위를 수행하도록 함.
-- https://leedo1982.github.io/wiki/ESC_CTRL_CAPSLOCK/
-- https://www.hammerspoon.org/docs/hs.eventtap.event.html#types
-- hs.eventtap.event.types.keyDown: modifier key가 아닌 다른 일반 key에 down이 발생했을 때
function escape_key_en_binding() 
  escape_keyevent = hs.eventtap.new (
    {hs.eventtap.event.types.keyDown},
    function (event)
      local flags = event:getFlags()
      local keycode = hs.keycodes.map[event:getKeyCode()]

      if (keycode == 'escape') then 
        -- print("This is escape")
        local input_korean = "com.apple.inputmethod.Korean.2SetKorean"
        local input_english = "com.apple.keylayout.ABC"

        if (hs.keycodes.currentSourceID() ~= input_english) then
          hs.keycodes.currentSourceID(input_english)
        end 
      end 
    end
  )
  escape_keyevent:start()
end
------------------------------------------------------------------------------------
-- 2022.03.20 - sng_hn.lee - test
-- hs.eventtap.event.types.flagsChanged: modifier key event 가 발생했을 때.
-- ctrl hjkl 에서도 한영변환이 발생하는데, 한영변환 발생하지 않도록 하려면?
-- ctrl이 눌렸을 때, 이 펑션이 실행되었다가, keyup이 발생하면 나가는 식으로 처리되어야 할 것 같다.
-- 2022.03.20 - sng_hn.lee - backup
-- 이거 그냥 ctrl 눌렸을 때 항상 한영 전환 두번씩 되도록 하면 되는거 아닌가?
function control_key_change_kor_en()
  control_keyevent = hs.eventtap.new (
    {
      hs.eventtap.event.types.flagsChanged, 
      hs.eventtap.event.types.keyDown
    },
    function (event)
      local flags = event:getFlags()
      local keycode = hs.keycodes.map[event:getKeyCode()]

      --control_release_event:start()
      --print("---------------------------------------")
      --print('containExactly ctrl: ', flags:containExactly({'ctrl'}))
      --print('keycode: ', keycode)
      if (flags:containExactly({'ctrl'}) == true) then
        -- ctrl pressed : true
        -- ctrl pressed > i pressed true
        -- shift pressed > ctrl pressed > shift released: true
        --print("only ctrl pressed")
        --print('flags.ctrl: ', flags.ctrl)

        if (flags.ctrl == true) then
          --print("This is ctrl")
          change_kor_en_input()
        end
      else
        --print('not only ctrl other pressed or released')
      end
    end
  )
  
  control_keyevent:start()
end
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- MAIN CODE
function main() 
  refresh_hammerspoon()
  all_arrow_key_binding()
  escape_key_en_binding()
  control_key_change_kor_en()
end
main()
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
