--[[
IMPLEMENTED
2022.03.19 - sng_hn.lee - 연속 키 입력시 키 입력 빠르게 되도록 변환
2022.03.19 - sng_hn.lee - ctrl + hjk 누르고 있으면 계속 눌러지도록 변환 필요: repeatFn
2022.03.19 - sng_hn.lee - ctrl 로 한영 변환
2022.03.20 - sng_hn.lee - escape 눌렀을 때 영어로 전환되도록 하는 함수 변경
2022.03.20 - sng_hn.lee - karabiner에서는 ctrl + shift hjkl 을 통해 block지정이 되는데, hammerspoon 에서는 안됨.
2022.03.21 - sng_hn.lee - ctrl + cmd + hjkl
2022.03.20 - sng_hn.lee - ctrl을 사용한 복합키를 누르면 항상 한영 변환이 한번 더 일어나도록 처리하여, 입력 소스가 변경되지 않도록 처리함.
2022.03.24 - sng_hn.lee - 키보드로 마우스 움직이고 클릭할 수 있도록 세팅함
-------------
NOT IMPLEMENTED YET
2022.03.19 - sng_hn.lee - karabiner에서는 기본적으로 FN + 4 -> go launchpad 등이 서포트되는데, hammerspoon 에서는 안됨.
- 이건 시스템 환경 설정 > 키보드 > 단축키 에서 설정할 수 있어서 수정함.
2022.03.21 - sng_hn.lee - Caps Lock key 생성 필요함. 다만, 이건 아래에 작성한 이유로 잘 안되느 것 같음.
-------------
--]]
------------------------------------------------------------------------------------
-- 2022.03.21 - sng_hn.lee - hammerspoon reload by shortcut
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
  end end
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
      -- print('containExactly ctrl: ', flags:containExactly({'ctrl'}))
      -- print('keycode: ', keycode)
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
-- 2022.03.22 - sng_hn.lee - fn + tab => Caps Lock
function ctrl_space_to_capslock()
  --[[
  2022.03.23 - sng_hn.lee
  - HHKB에서는 기본적으로 Fn + tab 에 Caps lock이 mapping되어 있다.
  - 다만 mac은 keyboard 기본 설정에서 "capslock을 이용해서 입력 소스 전환"을 설정할 수 있다.
  해당 기능을 활성화할 경우, capslock 키에 한영전환 키가 매핑되고, 키보드에서 capslock을 입력할 수 있는 방법은 사라진다.
  - 따라서, 해당 기능이 활성화되어 있는 상황에서는 HHKB에서 Fn + tab을 눌러도 capslock이 눌리지 않는다.
  - 또한, Fn 키는 해피해킹 자체에서 일종의 스위치처럼 키를 변경하는 것이어서, Fn 키가 눌리는 것을 맥 혹은 Hammerspoon에서 인식할 수 없다.
  - "capslock을 이용해서 입력 소스 전환"을 비활성화하면 capslock을 사용할 수 있지만, 이 경우 맥북 기본 키보드를 사용할 경우 입력 소스 전환이 조금 번거로워짐.
  - 맥에서의 기본적인 입력 소스 전환은 ctrl + space임. 현재는 ctrl을 사용하여, 한영전환을 하고 있으므로 ctrl + space는 사용하지 않는 상황.
  - 따라서, ctrl + space에 캡츠락 키가 매핑되도록 함.
  - ctrl이 눌리므로, 한영 전환도 발생하지 않도록 수정 필요함.
  --]]
  -- https://www.hammerspoon.org/docs/hs.hid.html
  --
  hs.hotkey.bind({"ctrl"}, 'space',
    function ()
      print('ctrl_space')
      -- 현재는 capslock이 없는 상황이기 때문에, 아래에서 오류가 발생함.
      -- ** Warning:hs.keycode: key '255' not found in active keymap or ANSI-standard US keyboard layout
      -- hs.hid.capslock.toggle()
    end
  )
end
------------------------------------------------------------------------------------
-- 2022.03.23 - sng_hn.lee
function print_keycode()
  key_code_print = hs.eventtap.new (
    {
      hs.eventtap.event.types.flagsChanged,
      hs.eventtap.event.types.keyDown
    },
    function (event)
      local flags = event:getFlags()
      local keycode = hs.keycodes.map[event:getKeyCode()]
      print(keycode)
    end
  )
  
  key_code_print:start()
end
------------------------------------------------------------------------------------
-- 2022.03.23 - sng_hn.lee - mouse 움직이도록 설ㅏ
function move_click_mouse ()
  --https://www.hammerspoon.org/docs/hs.mouse.html

  local function func_move_mouse_hjkl (key)
    local step_x_size = 30.0
    local step_y_size = 15.0

    local curr_relative_pos = hs.mouse.getRelativePosition()
    local curr_absolute_pos = hs.mouse.absolutePosition()
    local curr_abs_x = curr_absolute_pos['x']
    local curr_abs_y = curr_absolute_pos['y']

    --print('current absolute position: ', curr_abs_x, curr_abs_y)

    if (key == 'H') then
      --print('go mouse left')

      to_xy_pos = {x=curr_abs_x - step_x_size, y=curr_abs_y}
      hs.mouse.absolutePosition(to_xy_pos)
    elseif (key == 'J') then
      --print('go mouse down')

      to_xy_pos = {x=curr_abs_x, y=curr_abs_y + step_y_size}
      hs.mouse.absolutePosition(to_xy_pos)
    elseif (key == 'K') then
      --print('go mouse up')

      to_xy_pos = {x=curr_abs_x, y=curr_abs_y - step_y_size}
      hs.mouse.absolutePosition(to_xy_pos)
    elseif (key == 'L') then
      --print('go mouse right')

      to_xy_pos = {x=curr_abs_x + step_x_size, y=curr_abs_y}
      hs.mouse.absolutePosition(to_xy_pos)
    end
  end
  -- 현재 맥북에서는 abs, rel 값이 동일한 것 같음.
  for key, value in pairs({'H', 'J', 'K', 'L'}) do
    hs.hotkey.bind({'cmd', 'alt'}, value,
      function () func_move_mouse_hjkl(value) end,
      function () end,
      function () func_move_mouse_hjkl(value) end
    )
  end

  -- left click
  hs.hotkey.bind({'cmd', 'alt'}, 'U',
    function ()
      --print('-- click')
      local curr_absolute_pos = hs.mouse.absolutePosition()
      hs.eventtap.leftClick(curr_absolute_pos)
    end,
    function () end,
    function () end
  )
  -- right click
  hs.hotkey.bind({'cmd', 'alt'}, 'I',
    function ()
      --print('-- click')
      local curr_absolute_pos = hs.mouse.absolutePosition()
      hs.eventtap.rightClick(curr_absolute_pos)
    end,
    function () end,
    function () end
  )
end
------------------------------------------------------------------------------------
-- MAIN CODE
function main()
  print('-----------------------------------------------------')
  print('-- Hammerspoon console Start')
  --print_keycode()
  ctrl_space_to_capslock()

  refresh_hammerspoon()
  all_arrow_key_binding()
  escape_key_en_binding()
  control_key_change_kor_en()
  move_click_mouse()
  -- End of the Code
  hs.alert.show('Hammerspoon Reloaded Completed!')
  print('-----------------------------------------------------')
end
main()
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
