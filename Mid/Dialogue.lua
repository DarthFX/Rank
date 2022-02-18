local UIManager = require(script.Parent:WaitForChild("UI"))
local Settings = require(script:WaitForChild("Settings"))
local Lerper = require(game:GetService("ReplicatedStorage"):WaitForChild("Util").Lerper)
local IsAlreadyRunning = "Cannot edit already running dialogue instance: %s"

local CommaY, DefaultY = Settings.CommaPause, Settings.DefaultPause -- Y is short for Yield
local function SetDialogueVisible(Label, Bool)
    Label.Visible = true
    local Flippers = Label:FindFirstChild("Flippers")
    if Flippers then
        Flippers = Flippers:GetChildren()
        for _, Flipper in ipairs(Flippers) do
            Flipper.Visible = Bool
        end
    end
    if not Bool then
        Label.Text = ""
    end
end
local function DrawPages(Object, Start)
    local Label, Text = Object.Label, Object.Text
    local Page, Idx = Text[Start], 1
    Label.Text = ""
    Object.IsRunning = true
    while Idx <= #Page do
        if not Object.IsRunning then return end
        local Char = Page:sub(Idx, Idx)
        local Yield = ( Char == "," and CommaY ) or DefaultY
        Label.Text = Label.Text..Char
        Idx += 1
        task.wait(Yield)
    end
    Object.IsRunning = false
end
local EndTransitions = {}
local Meta = {}
Meta.__index = Meta

function Meta:FlipPage(Direction)
    if self.IsRunning then return end
    local Sum = self.Page + 1
    if Sum > #self.Text then
        if self.EndTransition then
            EndTransitions[self.EndTransition](self.Label)
        end
        self:Cleanup()
        return nil
    end
    self.Page += 1
    DrawPages(self, Sum)
end
function Meta:Cleanup()
    self.IsRunning = false
    if self.ColorAdjustments then
        Lerper.RemoveObject(self.Label.Name)
    end
    SetDialogueVisible(self.Label, false)
    self.Page = 1
end 
local Metadata = {}
local Dialogue = {}
function Dialogue.Run(Tag)
    local Object = Metadata[Tag]
    if Object.Label.Text ~= "" then
        warn(IsAlreadyRunning:format(Tag))
        return nil
    end
    if Object.ColorAdjustments then
        Lerper.AddTag(Object.Label.Name, Object.ColorAdjustments)
    end
    SetDialogueVisible(Object.Label, true)
    DrawPages(Object, Object.Page)
    return Object
end
for _, Transition in ipairs(script.EndTransitions:GetChildren()) do
    EndTransitions[Transition.Name] = require(Transition)
end
for _, Data in ipairs(script.Talks:GetChildren()) do
    local Contents = require(Data)
    local ColorAdjustments = Contents.ColorAdjustments
    Contents.IsRunning = false
    Contents.Page = 1
    Contents.Label = UIManager.Dialogues[Data.Name]
    if ColorAdjustments then
        ColorAdjustments.Parent = Contents.Label
        ColorAdjustments.Child = "TextColor3"
        ColorAdjustments.ResetOnDestroy = true
    end
    Metadata[Data.Name] = setmetatable(Contents, Meta)
end
return Dialogue
