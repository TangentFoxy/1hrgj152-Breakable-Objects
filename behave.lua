local Node, Decorate, Repeat
local running = setmetatable({ }, {
  __tostring = function()
    return "running"
  end
})
local make
make = function(tab)
  if "function" == type(tab) then
    return tab
  elseif tab.decorate then
    return Decorate(tab)
  elseif tab["repeat"] then
    return Repeat(tab)
  elseif "function" == type(tab.type) then
    return tab.type(tab)
  else
    return Node(tab)
  end
end
local get_nodes
get_nodes = function(tab)
  local nodes = { }
  for _index_0 = 1, #tab do
    local node = tab[_index_0]
    table.insert(nodes, make(node))
  end
  return nodes
end
Node = function(tab)
  local state, started = { }, false
  return function(...)
    local result
    if not (started) then
      if tab.start then
        result = tab.start(state, ...)
      end
      if not (result == false) then
        started = true
      end
    end
    if not (result == false) then
      result = tab.run(state, ...)
    end
    if result ~= running then
      started = false
      if result and tab.finish then
        result = tab.finish(state, ...)
      end
    end
    return result
  end
end
local Decorator
Decorator = function(tab)
  local node = make(tab[1])
  return function(...)
    local result = node(...)
    if not (result == running) then
      result = tab.decorate(result, ...)
    end
    return result
  end
end
local Inverted
Inverted = function(tab)
  local node = make(tab[1])
  return function(...)
    local result = node(...)
    if not (result == running) then
      return not result
    end
  end
end
Repeat = function(tab)
  local node = make(tab[1])
  local i, r = 1, tab["repeat"]
  return function(...)
    while i <= r do
      if running == node(...) then
        return running
      end
      i = i + 1
    end
    i = 1
    return true
  end
end
local Once
Once = function(tab)
  local node = make(tab[1])
  local ran = false
  return function(...)
    if ran then
      return false
    end
    local result = node(...)
    if not (result == running) then
      ran = true
    end
    return result
  end
end
local Selector
Selector = function(tab)
  local nodes = get_nodes(tab)
  local length = #nodes
  local i = 1
  return function(...)
    local result = nodes[i](...)
    while not result do
      i = i + 1
      if i > length then
        i = 1
        return false
      end
      result = nodes[i](...)
    end
    if result ~= running then
      i = 1
    end
    return result
  end
end
local Sequence
Sequence = function(tab)
  local nodes = get_nodes(tab)
  local length = #nodes
  local i = 1
  return function(...)
    local result = nodes[i](...)
    while result and result ~= running do
      i = i + 1
      if i > length then
        i = 1
        return result
      end
      result = nodes[i](...)
    end
    if not (result) then
      i = 1
    end
    return result
  end
end
local Random
Random = function(tab)
  local nodes = get_nodes(tab)
  local length = #nodes
  local r
  return function(...)
    if not (r) then
      r = 1 + math.random(length)
    end
    local result = nodes[r](...)
    if not (result == running) then
      r = nil
    end
    return result
  end
end
return {
  success = true,
  running = running,
  failure = false,
  make = make,
  Node = Node,
  Decorator = Decorator,
  Inverter = Inverter,
  Repeat = Repeat,
  Once = Once,
  Selector = Selector,
  Sequence = Sequence,
  Random = Random
}
