local this_module = {}

------------------------------------------------------------------------------------
-- 2022.03.27 - sng_hn.lee - arrow again
function this_module.stroke_arrow()
  -- hs.eventtap.keyStroke()의 경우 중간에 timer.usleep()이
  -- 포함되어 있어, 연속 입력이 어려우므로, 다음처럼 처리하였다.
  local arrow_table = {
    H='left', J='down', K='up', L='right'
  }

  kor_en_lang = require('kor_en_lang')
  for k, v in pairs(arrow_table) do
    hs.hotkey.bind({"ctrl"}, k,
      function ()
        local event = require("hs.eventtap").event
        --kor_en_lang.change_kor_en_input()
        event.newKeyEvent({}, v, true):post()
        event.newKeyEvent({}, v, false):post()
      end,
      function () end,
      function ()
        local event = require("hs.eventtap").event
        --kor_en_lang.change_kor_en_input()
        event.newKeyEvent({}, v, true):post()
        event.newKeyEvent({}, v, false):post()
      end
    )
  end
end

return this_module
