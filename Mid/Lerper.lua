local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local function AccToAlpha(Object)
    return Object.Acc / Object.Time
end
local function LinearInterpolate(A, B, T)
    return A + (B - A) * T
end
local function SafeLerp(Property)
    local Percent = TweenService:GetValue(AccToAlpha(Property), Property.Style, Property.Direction)
    if Property.IsNumber then
        Property.Parent[Property.Child] = LinearInterpolate(Property.Start, Property.End, Percent)
    else
        Property.Parent[Property.Child] = Property.Start:Lerp(Property.End, Percent)
    end
end
local Iterator = {}
function Iterator.Reverse(Property)
    local Idx = table.find(Property.Range, Property.End)
    if Idx == #Property.Range then
        Property.EndDirection = -1
        return Property.Range[Idx - 1]
    elseif Idx == 1 then
        Property.EndDirection = 1
        return Property.Range[2]
    end
    return Property.Range[Idx + Property.EndDirection]
end
function Iterator.Cycle(Object, Value)
    local Idx = table.find(Object.Range, Object.End)
    if Idx == #Object.Range then
        return Object.Range[1]
    end
    return Object.Range[Idx + 1]
end

local Objects = {}
local Lerper = {}
function Lerper.GetObject(Tag)
    return Objects[Tag]
end
function Lerper.RemoveObject(Tag)
    Lerper.GetObject(Tag).IsRunning = false
end
function Lerper.AddTag(Tag, Object)
    for _, Property in pairs(Object) do
        Property.Start = Property[1]
        Property.End = Property[2]
        Property.Acc = 0
        Property.IsNumber = type(Object.Start) == "number"
        Property.IsRunning = true
        Property.Parent = Property.Parent or Property
        Property.Child = Property.Child or "Result"
        if Property.IterType == "Reverse" then
            Property.EndDirection = 1
        end
        Property.IterType = Iterator[Property.IterType]
    end
    Object.Tag = Tag
    Objects[Tag] = Object
    return Object
end 
RunService.Heartbeat:Connect(function(Dt)
    for _, Object in pairs(Objects) do
        Object.Acc = Object.Acc + Dt
        if Object.IsRunning then
            for _, Property in pairs(Object.Properties) do
                if Property.Acc >= Property.Time then
                    Property.Start = Property.End
                    Property.End = Property.IterType(Property)
                    Property.Acc = 0
                end
                SafeLerp(Property)
            end
        else
            if Object.ResetOnDestroy then
                Object.Parent[Object.Child] = Object.Range[1]
            end
            Objects[Object.Tag] = nil
        end
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
        ResetOnDestroy = ...: Boolean (OPTIONAL)
        Child = ...: String (CHILD <-> Parent)
        Parent = ...: Instance (CHILD <-> Parent)
    }
--]]
