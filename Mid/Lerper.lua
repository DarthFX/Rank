local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local function AccToAlpha(Object)
    return Object.Acc / Object.Time
end
local function LinearInterpolate(A, B, T)
    return A + (B - A) * T
end
local function SafeLerp(Object)
    local Percent = TweenService:GetValue(AccToAlpha(Object), Object.Style, Object.Direction)
    if Object.IsNumber then
        Object.Parent[Object.Child] = LinearInterpolate(Object.Start, Object.End, Percent)
    else
        Object.Parent[Object.Child] = Object.Start:Lerp(Object.End, Percent)
    end
end
local Iterator = {}
function Iterator.Reverse(Object)
    local Idx = table.find(Object.Range, Object.End)
    if Idx == #Object.Range then
        Object.EndDirection = -1
        return Object.Range[Idx - 1]
    elseif Idx == 1 then
        Object.EndDirection = 1
        return Object.Range[2]
    end
    return Object.Range[Idx + Object.EndDirection]
end
function Iterator.Cycle(Object, Value)
    local Idx = table.find(Object.Range, Object.End)
    if Idx == #Object.Range then
        if Object.DisableOnCompletion then
            Object:SetRunning(false)
        end
        return Object.Range[1]
    end
    return Object.Range[Idx + 1]
end
local Running = {
    [true] = {},
    [false] = {}
}
local Meta = {}
Meta.__index = Meta

function Meta:SetRunning(Bool)
    self.IsRunning = Bool
    Running[Bool] = self
    Running[not Bool] = nil
    if not Bool and self.ResetOnDisable then
        self.Parent[self.Child] = self.Range[1]
    end
    return self
end
function Meta:Destroy()
    self:SetRunning(false)
    Running[self.IsRunning][self.Tag] = nil
end
local Lerper = {}
function Lerper.new(Tag, Object)
    Object.Start = Object.Range[1]
    Object.End = Object.Range[2]
    Object.Acc = 0
    Object.IsNumber = type(Object.Start) == "number"
    Object.IsRunning = true
    Object.Parent = Object.Parent or Object
    Object.Child = Object.Child or "Result"
    if Object.IterType == "Reverse" then
        Object.EndDirection = 1
    end
    Object.IterType = Iterator[Object.IterType]
    Object.Tag = Tag
    return setmetatable(Object, Meta)
end
function Lerper.GetObject(Tag) -- GLOBAL_ACCESS
    return Running.On[Tag] or Running.Off[Tag]
end
RunService.Heartbeat:Connect(function(Dt)
    for _, Object in pairs(Running[true]) do
        Object.Acc = Object.Acc + Dt
        if Object.Acc >= Object.Time then
            Object.Start = Object.End
            Object.End = Object.IterType(Object)
            Object.Acc = 0
        end
        SafeLerp(Object)
    end
end)
return Lerper
--[[
Object:
    {
        Range = {...: Any}
        Style = Enum.EasingStyle[...]
        Direction = Enum.EasingDirection[...]
        Time = ...: Number
        IterType: ...: String
        ResetOnDisable = ...: Boolean
        Child = ...: String (CHILD <-> Parent)
        Parent = ...: Instance | Object
    }
--]]
