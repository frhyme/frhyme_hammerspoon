local this_module = {}

function this_module.cmd_q_twice()
  -- 2022.04.03 - sng_hn.lee - Init, copy below URL
  -- https://gist.github.com/drewrothstein/3568a4624e2e9675fa0dfc2930e9eca5
  -- Press Cmd+Q twice to quit

  local quitModal = hs.hotkey.modal.new('cmd', 'q')

  function quitModal:entered()
    hs.alert.show("Press Cmd+Q again to quit in 1 seconds")
    -- 1초 동안 modal 상태에서 기다리다가 종료함.
    hs.timer.doAfter(
      1,
      function()
        --hs.alert.show('modal quit')
        quitModal:exit()
      end
    )
  end

  quitModal:bind('cmd', 'q',
    function ()
      -- 아래 코드가 먹히지 않아서 그냥 종료하는 것으로 변경함.
      --local res = hs.application.frontmostApplication():selectMenuItem("^Quit.*$")
      local front_most_app = hs.application.frontmostApplication()
      front_most_app:kill()
      --hs.alsert.show('frontmostApp killed')
      quitModal:exit()
    end
  )

  quitModal:bind('', 'escape',
    function()
      --hs.alert.show('cmd_q modal exit')
      quitModal:exit()
    end
  )
end

return this_module
