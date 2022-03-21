-- 2021.12.18 - esc 를 누르면 영어로 자동 전환되도록 변경함.

local input_english = "com.apple.keylayout.ABC"
local input_korean = "com.apple.inputmethod.Korean.2SetKorean"

-- lua에서 function을 변수에 집어넣을 수 있나?

function change_input_english ()
    if (hs.keycodes.currentSourceID() == input_english) then
        -- input_source를 영어로 변경해줌.
        hs.alert.show(input_english)
    elseif (hs.keycodes.currentSourceID() == input_korean) then
        hs.keycodes.currentSourceID(input_english)
    else
        hs.alert.show(hs.keycodes.currentSourceID)
    end
    -- 연달아 escape를 입력하게 되면, 키가 먹히지 않는 경우가 있어, 
    -- 아래와 같이 "right"라는 별 의미없는 키를 한 번 먹인다음 escape를 입력한다.
    hs.eventtap.keyStroke({}, "right")
    hs.eventtap.keyStroke({}, "escape")
end

hs.hotkey.bind({"control"}, "escape", change_input_english)

