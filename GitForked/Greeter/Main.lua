-- Greeter (Main.lua)
-- 1.1.0

-- Turbine imports
import "Turbine";
import "Turbine.UI";
import "Turbine.UI.Lotro";

-- Greeter imports
import "GitForked.Greeter.Greetings";
import "GitForked.Greeter.Welcomes";

function AddCallback(object, event, callback)
    if (object[event] == nil) then
        object[event] = callback;
    else
        if (type(object[event]) == "table") then
            table.insert(object[event], callback);
        else
            object[event] = {object[event], callback};
        end
    end
    return callback;
end

KinmateOnline = "has come online"
KinmateRecruited = "into your kinship"

function ChatHandler(sender, args)
    if args.ChatType == Turbine.ChatType.Kinship then
        -- Online
        if string.match(args.Message, KinmateOnline) then
            Turbine.Shell.WriteLine("<rgb=#008080>Greeter: </rgb> " .. args.Message);
            -- Get player name
            local PlayerName = args.Message:match("^(%S+)")
            -- Choose a greeting with dynamic quickslots
            local quickslots = {}
            local size = 40
            GreeterWindow:SetVisible(true)
            -- Assign shortcuts dynamically
            listBox:ClearItems()
            for i = 1, #Greetings do
                -- Replace <Player Name> with the player's name
                local greetings, count = string.gsub(Greetings[i], "<Player Name>", PlayerName)
                quickslots[i] = Turbine.UI.Lotro.Quickslot()
                quickslots[i]:SetSize(size, size)
                quickslots[i]:SetBackground(0x410001c9)
                quickslots[i]:SetVisible(true)
                quickslots[i]:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, "/k " .. greetings))
                quickslots[i].MouseClick = function(sender, args)
                    GreeterWindow:SetVisible(false)
                end
                listBox:AddItem(quickslots[i])
            end
        end
        -- Recruited
        if string.match(args.Message, KinmateRecruited) then
            Turbine.Shell.WriteLine("<rgb=#008080>Greeter: </rgb> " .. args.Message);
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
                -- Replace <Player Name> with the player's name
                local welcomes, count = string.gsub(Welcomes[i], "<Player Name>", PlayerName)
                quickslots[i] = Turbine.UI.Lotro.Quickslot()
                quickslots[i]:SetSize(size, size)
                quickslots[i]:SetBackground(0x410001c9)
                quickslots[i]:SetVisible(true)
                quickslots[i]:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, "/k " .. welcomes))
                quickslots[i].MouseClick = function(sender, args)
                    GreeterWindow:SetVisible(false)
                end
                listBox:AddItem(quickslots[i])
            end
        end
    end
end

AddCallback(Turbine.Chat, "Received", ChatHandler);

-- Create a window
GreeterWindow = Turbine.UI.Lotro.Window()
GreeterWindow:SetSize(250, 100)
GreeterWindow:SetPosition(400, 400)
GreeterWindow:SetVisible(true)
GreeterWindow:SetText("Greeter")
GreeterWindow:SetVisible(false)

-- Create a scrollbar
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

-- Load message
Turbine.Shell.WriteLine("<rgb=#008080>Greeter</rgb> " .. Plugins.Greeter:GetVersion() .. " by <rgb=#008080>Git-Forked</rgb> loaded.");
