if SERVER then
    util.AddNetworkString("HZNBuffs:Say")
    function HZNBuffs:Say(ply, msg)
        net.Start("HZNBuffs:Say")
        net.WriteString(msg)
        net.Send(ply)
    end
else
    net.Receive("HZNBuffs:Say", function()
        local msg = net.ReadString()
        
        chat.AddText(Color(199, 112, 46), "[Buffs] ", Color(255, 255, 255), msg)
    end)

    function HZNBuffs:Say(msg)
        chat.AddText(Color(199, 112, 46), "[Buffs] ", Color(255, 255, 255), msg)
    end
end