-- 2021.12.18 - esc 를 누르면 영어로 자동 전환되도록 변경함.

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


-- 2022.03.19 - sng_hn.lee - Arrow keys
hs.hotkey.bind({"ctrl"}, "h", function()
  hs.alert.show("go left")
  hs.eventtap.keyStroke({}, "right")
end)
