local Node, Decorate, Repeat

running = setmetatable {}, __tostring: -> return "running"

-- produces a callable function from a defined node or full behavior tree
make = (tab) ->
  if "function" == type tab
    return tab
  elseif tab.decorate
    return Decorate tab
  elseif tab.repeat
    return Repeat tab
  elseif "function" == type tab.type
    return tab.type tab
  else
    return Node tab

get_nodes = (tab) ->
  nodes = {}
  for node in *tab
    table.insert nodes, make node
  return nodes

-- complex leaf node
--  state is preserved through calls, optional start/finish functions
Node = (tab) ->
  state, started = {}, false
  return (...) ->
    local result
    unless started
      result = tab.start state, ... if tab.start
      started = true unless result == false
    result = tab.run state, ... unless result == false
    if result != running
      started = false
      result = tab.finish state, ... if result and tab.finish
    return result

-- modifies the result of a node before returning it
Decorator = (tab) ->
  node = make tab[1]
  return (...) ->
    result = node(...)
    result = tab.decorate result, ... unless result == running
    return result

-- inverts the result of a node before returning it
Inverted = (tab) ->
  node = make tab[1]
  return (...) ->
    result = node(...)
    return not result unless result == running

Repeat = (tab) ->
  node = make tab[1]
  i, r = 1, tab.repeat
  return (...) ->
    while i <= r
      return running if running == node(...)
      i += 1
    i = 1
    return true

Once = (tab) ->
  node = make tab[1]
  ran = false
  return (...) ->
    return false if ran
    result = node(...)
    unless result == running
      ran = true
    return result

-- returns first success/running, or failure
Selector = (tab) ->
  nodes = get_nodes tab
  length = #nodes
  i = 1
  return (...) ->
    result = nodes[i](...)
    while not result
      i += 1
      if i > length
        i = 1
        return false
      result = nodes[i](...)
    i = 1 if result != running
    return result

-- returns first running/failure, or success
Sequence = (tab) ->
  nodes = get_nodes tab
  length = #nodes
  i = 1
  return (...) ->
    result = nodes[i](...)
    while result and result != running
      i += 1
      if i > length
        i = 1
        return result
      result = nodes[i](...)
    i = 1 unless result
    return result

-- returns success/running/failure from random child
Random = (tab) ->
  nodes = get_nodes tab
  length = #nodes
  local r
  return (...) ->
    unless r
      r = 1 + math.random length
    result = nodes[r](...)
    unless result == running
      r = nil
    return result

{
  success: true
  :running
  failure: false

  :make
  :Node

  :Decorator
  :Inverter
  :Repeat
  :Once

  :Selector
  :Sequence
  :Random
}
