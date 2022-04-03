## About this Repository

- MacBook에서 HHKB를 사용해서 개발을 하고 있습니다.
- 한영 변환이나, ctrl + hjkl 등의 키를 화살표로 사용하는 것 등 자잘한 기능들을 hammerspoon을 사용해서 개발하고 있습니다.
- 기존에는 karabiner를 사용하였으나, hammerspoon은 좀 더 다양하게 사용할 수 있어 편리한 것 같네요.
- [frhyme - frhyme_hammerspoon](https://github.com/frhyme/frhyme_hammerspoon)

## Log

### IMPLEMENTED

- 2022.03.19 - sng_hn.lee - 연속 키 입력시 키 입력 빠르게 되도록 변환
- 2022.03.19 - sng_hn.lee - ctrl + hjk 누르고 있으면 계속 눌러지도록 변환 필요: repeatFn
- 2022.03.19 - sng_hn.lee - ctrl 로 한영 변환
- 2022.03.20 - sng_hn.lee - escape 눌렀을 때 영어로 전환되도록 하는 함수 변경
- 2022.03.20 - sng_hn.lee - karabiner에서는 ctrl + shift hjkl 을 통해 block지정이 되는데, hammerspoon 에서는 안됨.
- 2022.03.21 - sng_hn.lee - ctrl + cmd + hjkl
- 2022.03.20 - sng_hn.lee - ctrl을 사용한 복합키를 누르면 항상 한영 변환이 한번 더 일어나도록 처리하여, 입력 소스가 변경되지 않도록 처리함.
- 2022.03.24 - sng_hn.lee - 키보드로 마우스 움직이고 클릭할 수 있도록 세팅함
- 2022.03.28 - sng_hn.lee - 키 입력시 버퍼링과 한영 전환 시 이상함 등이 있어서 전반적으로 코드를 수정중
- 2022.03.30 - sng_hn.lee - Code 들을 다른 파일들로 분리함.
- 2022.04.03 - sng_hn.lee - cmd q 눌렀을 때 app이 바로 종료되지 않고, 1초 내에 다시 cmd q를 눌렀을 때 종료되도록 처리함.

### NOT IMPLEMENTED YET

- 2022.03.19 - sng_hn.lee - karabiner에서는 기본적으로 FN + 4 -> go launchpad 등이 서포트되는데, hammerspoon 에서는 안됨.
  - 이건 시스템 환경 설정 > 키보드 > 단축키 에서 설정할 수 있어서 수정함.
- 2022.03.21 - sng_hn.lee - Caps Lock key 생성 필요함. 다만, 이건 아래에 작성한 이유로 잘 안되느 것 같음.
- 2022.03.25 - sng_hn.lee - ctrl + hjkl 을 누르고 있을 때, 키 입력과 화면 커서 움직임 간에 버퍼링이 있음. 커서가 늦게 움직이거나 버퍼링이 생겨서 나중에 움직임
- 2022.03.28 - sng_hn.lee - function module화 필요함
- 2022.03.30 - sng_hn.lee - ctrl 눌릴 때마다, kor => en 변경이 계속 일어나도록 하면 버퍼링이 발생함.
