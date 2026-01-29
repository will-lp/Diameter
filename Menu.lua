local addonName, Diameter = ...

function Diameter:ShowMenu(anchor)
    -- This is the modern 11.0+ Menu API
    MenuUtil.CreateContextMenu(anchor, function(owner, rootDescription)
        rootDescription:CreateTitle("Select Mode")
        
        rootDescription:CreateButton("Damage Done", function() 
            print("Switched to Damage")
            -- Set mode variable here
        end)
        
        rootDescription:CreateButton("Healing", function() 
            print("Switched to Healing")
        end)

        rootDescription:CreateDivider()
        
        rootDescription:CreateButton("Reset Data", function() 
            C_DamageMeter.ResetAllCombatSessions()
        end)
    end)
end