-- Greeter (Main.lua)

-- Turbine imports
import "Turbine"
import "Turbine.UI"
import "Turbine.UI.Lotro"

-- Greeter imports
import "GitForked.Greeter.Greetings"
import "GitForked.Greeter.Welcomes"

function AddCallback(object, event, callback)
    if (object[event] == nil) then
        object[event] = callback
    else
        if (type(object[event]) == "table") then
            table.insert(object[event], callback)
        else
            object[event] = {object[event], callback}
        end
    end
    return callback
end

KinmateOnline = "has come online"
KinmateRecruited = "into your kinship"

function ChatHandler(sender, args)
    if args.ChatType == Turbine.ChatType.Kinship then
        -- Online
        if string.match(args.Message, KinmateOnline) then
            Turbine.Shell.WriteLine("<rgb=#008080>Greeter: </rgb> " .. args.Message)
            -- Get player name
            local PlayerName = args.Message:match("^(%S+)")
            -- Choose a greeting with dynamic quickslots
            local quickslots = {}
            local size = 40
            GreeterWindow:SetVisible(true)
            -- Assign shortcuts dynamically
            listBox:ClearItems()
            for i = 1, #Greetings do
                -- Replace <Player Name> with the player's name & Replace <Kinship Name> with the kinship name
                local greeting = Greetings[i]:gsub("<Player Name>", PlayerName):gsub("<Kinship Name>", KinshipName)
                --
                quickslots[i] = Turbine.UI.Lotro.Quickslot()
                quickslots[i]:SetSize(size, size)
                quickslots[i]:SetBackground(0x410001c9)
                quickslots[i]:SetVisible(true)
                quickslots[i]:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, "/k " .. greeting))
                quickslots[i].MouseClick = function(sender, args)
                    GreeterWindow:SetVisible(false)
                end
                listBox:AddItem(quickslots[i])
            end
        end
        -- Recruited
        if string.match(args.Message, KinmateRecruited) then
            Turbine.Shell.WriteLine("<rgb=#008080>Greeter: </rgb> " .. args.Message)
            -- Get player name
            local PlayerName = nil
            local c = 0
            for word in args.Message:gmatch("%S+") do
                c = c + 1
                if c == 4 then
                    PlayerName = word
                    break
                end
            end
            -- Choose a greeting with dynamic quickslots
            local quickslots = {}
            local size = 40
            GreeterWindow:SetVisible(true)
            -- Assign shortcuts dynamically
            listBox:ClearItems()
            for i = 1, #Welcomes do
                -- Replace <Player Name> with the player's name & Replace <Kinship Name> with the kinship name
                local welcome = Welcomes[i]:gsub("<Player Name>", PlayerName):gsub("<Kinship Name>", KinshipName)
                --
                quickslots[i] = Turbine.UI.Lotro.Quickslot()
                quickslots[i]:SetSize(size, size)
                quickslots[i]:SetBackground(0x410001c9)
                quickslots[i]:SetVisible(true)
                quickslots[i]:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, "/k " .. welcome))
                quickslots[i].MouseClick = function(sender, args)
                    GreeterWindow:SetVisible(false)
                end
                listBox:AddItem(quickslots[i])
            end
        end
    end
end

AddCallback(Turbine.Chat, "Received", ChatHandler)

-- Window
GreeterWindow = Turbine.UI.Lotro.Window()
GreeterWindow:SetSize(250, 100)
GreeterWindow:SetPosition(400, 400)
GreeterWindow:SetVisible(true)
GreeterWindow:SetText("Greeter")
GreeterWindow:SetVisible(false)

-- Scrollbar
scrollBar = Turbine.UI.Lotro.ScrollBar()
scrollBar:SetOrientation(Turbine.UI.Orientation.Horizontal)
scrollBar:SetParent(GreeterWindow)
scrollBar:SetSize(220, 10)
scrollBar:SetPosition(15, 77)

-- ListBox (the scrollable container)
listBox = Turbine.UI.ListBox()
listBox:SetParent(GreeterWindow)
listBox:SetPosition(15, 35)
listBox:SetSize(220, 40)
listBox:SetOrientation(Turbine.UI.Orientation.Horizontal)
listBox:SetHorizontalScrollBar(scrollBar)
listBox:SetMaxItemsPerLine(#Greetings)  -- quickslots per row (all of them)

-- Options Panel
optionsPanel = Turbine.UI.Control()
optionsPanel:SetBackColor(Turbine.UI.Color(0.1, 0.1, 0.1))
optionsPanel:SetWidth(250)
optionsPanel:SetHeight(125)

-- Kinship Name label for text box
local label = Turbine.UI.Label()
label:SetParent(optionsPanel)
label:SetSize(250, 20)
label:SetPosition(10, 10)
label:SetText("Enter your kinship name here: ")
label:SetFont(Turbine.UI.Lotro.Font.TrajanPro18)  -- matches game font

-- Kinship Name text box
textBox = Turbine.UI.Lotro.TextBox()
textBox:SetParent(optionsPanel)
textBox:SetSize(250, 30) -- Width, Height
textBox:SetPosition(10, 30) -- X, Y relative to parent
textBox:SetText("") -- Initial value

-- Save button
saveButton = Turbine.UI.Lotro.Button()
saveButton:SetParent(optionsPanel)
saveButton:SetSize(80, 25)
saveButton:SetPosition(10, 65)
saveButton:SetText("Save")

saveButton.Click = function(self)
    KinshipName = textBox:GetText()
    Turbine.PluginData.Save(Turbine.DataScope.Character, "Greeter", KinshipName)
end

-- Register the options panel with the plugin manager
plugin.GetOptionsPanel = function(self)
    return optionsPanel
end

-- Initialization
KinshipName = nil
if Turbine.PluginData.Load(Turbine.DataScope.Character, "Greeter") ~= nil then
    KinshipName = Turbine.PluginData.Load(Turbine.DataScope.Character, "Greeter")
    textBox:SetText(KinshipName)
end
if KinshipName == nil then
    KinshipName = "our kinship"
end

-- Load message
Turbine.Shell.WriteLine("<rgb=#008080>Greeter</rgb> " .. Plugins.Greeter:GetVersion() .. " by <rgb=#008080>Git-Forked</rgb> loaded.")
