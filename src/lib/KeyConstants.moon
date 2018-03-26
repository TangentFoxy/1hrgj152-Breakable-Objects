KeyConstants = {
  character: {
    space: true
  }
  numpad: {
    kpenter: true
  }
  navigation: {
    up: true
    down: true
    right: true
    left: true
    home: true
    "end": true
    pageup: true
    pagedown: true
  }
  editing: {
    insert: true
    backspace: true
    tab: true
    clear: true
    "return": true
    delete: true
  }
  "function": {}
  modifier: {
    numlock: true
    capslock: true
    scrolllock: true
    rshift: true
    lshift: true
    rctrl: true
    lctrl: true
    ralt: true
    lalt: true
    rgui: true
    lgui: true
    mode: true
  }
  application: {
    www: true
    mail: true
    calculator: true
    computer: true
    appsearch: true
    apphome: true
    appback: true
    appforward: true
    apprefresh: true
    appbookmarks: true
  }
  miscellaneous: {
    pause: true
    escape: true
    help: true
    printscreen: true
    sysreq: true
    menu: true
    application: true
    power: true
    currencyunit: true
    undo: true
  }
}

character = "abcdefghijklmnopqrstuvwxyz0123456789 !\"#$&'()*+,-./:;<=>?@[\\]^_`"
for i = 1, #character
  KeyConstants.character[character\sub i, i] = true

numpad = "0123456789.,/*-+="
for i = 1, #numpad
  KeyConstants.numpad["kp#{numpad\sub i, i}"] = true

-- function keys
for i = 1, 18
  KeyConstants["function"]["f#{i}"] = true

return KeyConstants
