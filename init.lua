--[[
LOG
2022.03.28 - sng_hn.lee - 키 입력시 버퍼링과 한영 전환 시 이상함 등이 있어서 전반적으로 코드를 수정중
2022.03.30 - sng_hn.lee - Code 들을 다른 파일들로 분리함.
-------------
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
2022.03.25 - sng_hn.lee - ctrl + hjkl 을 누르고 있을 때, 키 입력과 화면 커서 움직임 간에 버퍼링이 있음. 커서가 늦게 움직이거나 버퍼링이 생겨서 나중에 움직임
2022.03.28 - sng_hn.lee - function module화 필요함
2022.03.30 - sng_hn.lee - ctrl 눌릴 때마다, kor => en 변경이 계속 일어나도록 하면 버퍼링이 발생함.
-------------
--]]
------------------------------------------------------------------------------------
-- lib list
kor_en_lang_lib = require('kor_en_lang')
hjkl_arrow_lib = require('arrow')
mouse_lib = require('mouse')
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
-- 2022.03.23 - sng_hn.lee - key 조합을 알기 위해 사용
function print_keycode()
  key_code_print = hs.eventtap.new (
    {
      hs.eventtap.event.types.flagsChanged,
      hs.eventtap.event.types.keyDown
    },
    function (event)
      local flags = event:getFlags()
      local keycode = hs.keycodes.map[event:getKeyCode()]
      --print('== print_keycode ========================')
      print('keycode: ', keycode)
      print('flags: ', flags, ' = ', flags.ctrl, ' = ', flags:containExactly({'ctrl'}))
      if (keycode == 'ctrl' and flags.ctrl == nil and flags:containExactly({'ctrl'}) == false) then
        print('=== key released')
      end
      --print('==========================================')
    end
  )
  
  key_code_print:start()
end
------------------------------------------------------------------------------------
-- 2022.03.30 - sng_hn.lee - ctrl release change kor en
-- 완성했다 씨바!!!!
-- ctrl이 단독으로 눌리는 경우에는 한영 변환을 진행하고,
-- ctrl이 눌린 상태에서, hjkl이 눌린 적이 있으면, 이전 입력 소스로 변경함
-- arrow(Fn + [;/')이 입력되었을 때도 변환되지 않도록 처리함
-- 제외되어야 하는 key_code 들을 set로 빼서, contain 등으로 처리하는 것이 필요함
input_before_ctrl_pressed = nil
hjkl_press_count_during_ctrl_pressed = 0

function only_ctrl_change_kor_en()
  local_function = hs.eventtap.new (
    {
      hs.eventtap.event.types.flagsChanged,
      hs.eventtap.event.types.keyDown
    },
    function (event)
      input_before_ctrl_pressed = hs.keycodes.currentSourceID()

      local flags = event:getFlags()
      local keycode = hs.keycodes.map[event:getKeyCode()]
      --print('hjkl_press_count: ', hjkl_press_count)
      --print('== print_keycode ========================')
      if (keycode == 'ctrl' and flags.ctrl == true and flags:containExactly({'ctrl'}) == true) then
        --print('== ctrl key pressed')
        hjkl_press_count_during_ctrl_pressed = 0
      elseif (keycode == 'h' or keycode == 'j' or keycode == 'k' or keycode == 'l') then
        hjkl_press_count_during_ctrl_pressed = hjkl_press_count_during_ctrl_pressed  + 1
      elseif (keycode == 'left' or keycode == 'right' or keycode == 'up' or keycode == 'down') then
        hjkl_press_count_during_ctrl_pressed = hjkl_press_count_during_ctrl_pressed  + 1
      elseif (keycode == 'ctrl' and flags.ctrl == nil and flags:containExactly({'ctrl'}) == false) then
        --print('== ctrl key released')
        if (hjkl_press_count_during_ctrl_pressed== 0) then
          -- ctrl press 이후 hjkl이 눌린 적 없으므로 변환
          kor_en_lang_lib.change_kor_en_input()
        else
          -- ctrl 이후 hjkl이 눌렸으므로 이전 input으로 변경함
          hs.keycodes.currentSourceID(input_before_ctrl_pressed)
        end
      end
      --print('==========================================')
    end
  )
  local_function:start()
end
------------------------------------------------------------------------------------
-- MAIN CODE
function main()
  print('-----------------------------------------------------')
  print('-- Hammerspoon console Start')
  ctrl_space_to_capslock()

  refresh_hammerspoon()
  escape_key_en_binding()
  only_ctrl_change_kor_en()

  hjkl_arrow_lib.stroke_arrow()


  mouse_lib.move_click_mouse()
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
