local function CreateWillenserklaerung(declaration_text, handlung, erklaerung, geschaeft)
    -- ==========================================
    -- PRIVATE STATE (The Human Mind)
    -- Completely inaccessible from the outside
    -- ==========================================
    local private_state = {
        Handlungswille = handlung or false,
        Erklaerungsbewusstsein = erklaerung or false,
        Geschaeftswille = geschaeft or false
    }
    -- ==========================================
    -- PUBLIC API (The Objektiver Tatbestand)
    -- What the employer/contract partner actually sees
    -- ==========================================
    local public_api = {
        declaration = declaration_text or ""
    }

    function public_api:FireEvent()
        -- 1. The Ultimate Null Check (No conscious action = No legal event)
        if not private_state.Handlungswille then
            error("[FATAL BGB EXCEPTION]: Kein Handlungswille! Input rejected (Reflex, Sleep, or Physical Force).")
        end
        -- 2. The Trier Wine Auction Bug (You acted, but didn't know it was legal)
        if not private_state.Erklaerungsbewusstsein then
            print("[WARNING]: Missing Erklärungsbewusstsein! Event compiled, but vulnerable to rollback (Anfechtung § 119 BGB).")
            print(" >> Executing public action: " .. self.declaration)
            return
        end
        -- 3. The Minor Typo (You knew it was legal, but wanted something else)
        if not private_state.Geschaeftswille then
            print("[INFO]: Missing Geschäftswille. Contract active, but minor rollback possible.")
            print(" >> Executing public action: " .. self.declaration)
            return
        end
        -- 4. Perfect Payload
        print("[SUCCESS]: Perfect Willenserklärung. Executing: " .. self.declaration)
    end
    -- ==========================================
    -- METATABLE MAGIC (The BGB Firewall)
    -- ==========================================
    local proxy = {}
    
    setmetatable(proxy, {
        -- Route all valid public reads to the public API
        __index = public_api,
        -- Block unauthorized writes to the object
        __newindex = function(table, key, value)
            if key == "declaration" then
                public_api.declaration = value
            else
                error("[ACCESS DENIED]: You cannot forcibly alter internal BGB mental attributes from the outside!")
            end
        end,
        -- Make it look pretty when you print(object)
        __tostring = function()
            local status = private_state.Handlungswille and "Active" or "Void"
            return "[BGB Object: Willenserklärung | Status: " .. status .. "]"
        end
    })

    return proxy
end
-- ==========================================
-- RUNTIME TESTS
-- ==========================================
-- print("--- TEST 1: The Trier Wine Auction ---")
-- Hand raised intentionally (true), didn't know it was a bid (false), didn't want the wine (false)
-- local wineBid = CreateWillenserklaerung("Raises hand to wave at friend", true, false, false)
-- wineBid:FireEvent()
-- Output: [WARNING] Event compiled, but vulnerable to rollback...
-- print("\n--- TEST 2: The Perfect Kündigung ---")
-- local termination = CreateWillenserklaerung("Hands over signed termination letter", true, true, true)
-- termination:FireEvent()
-- Output: [SUCCESS] Executing: Hands over signed termination letter
-- print("\n--- TEST 3: External Tampering (Hacking the BGB) ---")
-- local rogueEmployer = CreateWillenserklaerung("Nods head", true, true, true)
-- local success, err = pcall(function()
    -- An external script tries to forcibly change your mental state
    -- rogueEmployer.Handlungswille = false 
-- end)
-- if not success then
    -- print(err)
    -- Output: [ACCESS DENIED]: You cannot forcibly alter internal BGB mental attributes!
-- end
return CreateWillenserklaerung
