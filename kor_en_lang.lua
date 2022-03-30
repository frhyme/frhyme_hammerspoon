local this_module = {}

------------------------------------------------------------------------------------
-- 2022.03.30 - sng_hn.lee -
function this_module.change_kor_en_input ()
  -- 2022.03.22 - sng_hn.lee - 한영전환 함수
  --print("This is ctrl")
  local input_korean = "com.apple.inputmethod.Korean.2SetKorean"
  local input_english = "com.apple.keylayout.ABC"
  -- local input_source = hs.keycodes.currentSourceID()
  --hs.alert.show(hs.keycodes.currentSourceID())

  if (hs.keycodes.currentSourceID() == input_english) then
    --hs.alert.show( hs.keycodes.currentSourceID() .. ' => ' .. 'Korean')
    --print('english - korean')
    hs.keycodes.currentSourceID(input_korean)
  else
    --hs.alert.show( hs.keycodes.currentSourceID() .. ' => ' .. 'English')
    --print('korean - english')
    hs.keycodes.currentSourceID(input_english)
  end
end
return this_module
