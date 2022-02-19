local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Player = game:GetService("Players").LocalPlayer

local GameStarted = ReplicatedStorage
    :WaitForChild("Bindables")
    :WaitForChild("GameStarted")
local Container = Player.PlayerGui
    :WaitForChild("Test")
    :WaitForChild("Background")
local ButtonRatio = 1.15
local function ResizeLabel(Label, Size)
    local LabelAnim = TweenService:Create(Label, TweenInfo.new(0.3), 
        {Size = UDim2.new(Label.Size.X.Scale * Size, 0, Label.Size.Y.Scale * Size, 0)}
    )
    return function()
        LabelAnim:Play()
    end
end
local UIManager = {}
UIManager.Container = Container
function UIManager.SetDescendantsVisible(Parent, Bool)
    local Descendants = Parent:GetDescendants()
    for _, Descendant in ipairs(Descendants) do
        if Descendant:IsA("Folder") then
            continue
        end
        Descendant.Visible = Bool
    end
end
function UIManager.HandleTimer(Timer, Tag)
    local Label = Container.Timers[Tag]
    Label.Visible = true
    while Timer:IsRunning() do
        Label.Text = Timer:GetTimeLeft()
        task.wait()
    end
    Label.Visible = false
end

local PregameEvents = {}
function PregameEvents.Play()
    UIManager.SetDescendantsVisible(UIManager.Pregame, false)
    GameStarted:Fire()
end
PregameEvents.Settings = function() end
for _, MiniContainer in ipairs(UIManager.Container:GetChildren()) do
    UIManager[MiniContainer.Name] = MiniContainer
end
for _, Label in ipairs(UIManager.Pregame.Buttons:GetChildren()) do
    local Button = Label.Button
    Button.MouseEnter:Connect(ResizeLabel(Label, ButtonRatio))
    Button.MouseLeave:Connect(ResizeLabel(Label, 1 / ButtonRatio))
    Button.MouseButton1Click:Connect(PregameEvents[Label.Name])
end
StarterGui:SetCore("TopbarEnabled", false)
return UIManager
