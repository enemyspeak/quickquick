local Stateful = { static = {} }

local _callbacks = {
  enteredState = 1,
  exitedState = 1,
  pushedState = 1,
  poppedState = 1,
  pausedState = 1,
  continuedState = 1
}
 
local _BaseState = {}

for callbackName,_ in pairs(_callbacks) do
  _BaseState[callbackName] = function() end
end

local function _addStatesToClass(klass, superStates)
  klass.static.states = {}
  for stateName, state in pairs(superStates or {}) do
    klass.static.states[stateName] = setmetatable({}, { __index = state })
  end
end

local function _getStatefulMethod(instance, name)
  if not _callbacks[name] then
    local stack = rawget(instance, '__stateStack')
    if not stack then return end
    for i = #stack, 1, -1 do
      if stack[i][name] then return stack[i][name] end
    end
  end
end

local function _getNewInstanceIndex(prevIndex)
  if type(prevIndex) == 'function' then
    return function(instance, name) return _getStatefulMethod(instance, name) or prevIndex(instance, name) end
  end
  return function(instance, name) return _getStatefulMethod(instance, name) or prevIndex[name] end
end

local function _getNewAllocateMethod(oldAllocateMethod)
  return function(klass, ...)
    local instance = oldAllocateMethod(klass, ...)
    instance.__stateStack = {}
    return instance
  end
end

local function _modifyInstanceIndex(klass)
  klass.__instanceDict.__index = _getNewInstanceIndex(klass.__instanceDict.__index)
end

local function _getNewSubclassMethod(prevSubclass)
  return function(klass, name)
    local subclass = prevSubclass(klass, name)
    _addStatesToClass(subclass, klass.states)
    _modifyInstanceIndex(subclass)
    return subclass
  end
end

local function _modifySubclassMethod(klass)
  klass.static.subclass = _getNewSubclassMethod(klass.static.subclass)
end

local function _modifyAllocateMethod(klass)
  klass.static.allocate = _getNewAllocateMethod(klass.static.allocate)
end

local function _assertType(val, name, expected_type, type_to_s)
  assert(type(val) == expected_type, "Expected " .. name .. " to be of type " .. (type_to_s or expected_type) .. ". Was " .. tostring(val) .. "(" .. type(val) .. ")")
end

local function _assertInexistingState(klass, stateName)
  assert(klass.states[stateName] == nil, "State " .. tostring(stateName) .. " already exists on " .. tostring(klass) )
end

local function _assertExistingState(self, state, stateName)
  assert(state, "The state" .. stateName .. " was not found in class " .. tostring(self.class) )
end

local function _invokeCallback(self, state, callbackName)
  if state then state[callbackName](self) end
end

local function _getCurrentState(self)
  return self.__stateStack[#self.__stateStack]
end

local function _getStateFromClassByName(self, stateName)
  local state = self.class.static.states[stateName]
  _assertExistingState(self, state, stateName)
  return state
end
local function _getStateIndexFromStackByName(self, stateName)
  if stateName == nil then return #self.__stateStack end
  local target = _getStateFromClassByName(self, stateName)
  for i = #self.__stateStack, 1, -1 do
    if self.__stateStack[i] == target then return i end
  end
  return 0
end

function Stateful:included(klass)
  _addStatesToClass(klass)
  _modifyInstanceIndex(klass)
  _modifySubclassMethod(klass)
  _modifyAllocateMethod(klass)
end

function Stateful.static:addState(stateName)
  _assertType(stateName, 'stateName', 'string')
  _assertInexistingState(self, stateName)
  self.static.states[stateName] = setmetatable({}, { __index = _BaseState })
  return self.static.states[stateName]
end

function Stateful:gotoState(stateName)

  _invokeCallback(self, _getCurrentState(self), 'exitedState')

  if stateName == nil then
    self.__stateStack = { }
  else
    _assertType(stateName, 'stateName', 'string', 'string or nil')

    local newState = _getStateFromClassByName(self, stateName)
    _invokeCallback(self, newState, 'enteredState')
    self.__stateStack = { newState }
  end

end

function Stateful:pushState(stateName)
  local oldState = _getCurrentState(self)
  _invokeCallback(self, oldState, 'pausedState')
  _invokeCallback(self, oldState, 'exitedState')

  local newState = _getStateFromClassByName(self, stateName)
  _invokeCallback(self, newState, 'pushedState')
  _invokeCallback(self, newState, 'enteredState')
  table.insert(self.__stateStack, newState)
end

function Stateful:popState(stateName)
  local oldStateIndex = _getStateIndexFromStackByName(self, stateName)
  local oldState = self.__stateStack[oldStateIndex]

  _invokeCallback(self, oldState, 'poppedState')
  _invokeCallback(self, oldState, 'exitedState')

  table.remove(self.__stateStack, oldStateIndex)

  local newState = _getCurrentState(self)

  if oldState ~= newState then
    _invokeCallback(self, newState, 'continuedState')
  end
end

function Stateful:popAllStates()
  self.__stateStack = {}
end

return Stateful
