-- ========================================================================
-- ULTIMA PLATIN: BGB TERMINAL COMPANION
-- Interactive Lua CLI for Personalkündigung
-- ========================================================================

-- ANSI Color Codes for the Terminal
local c_red = "\27[31m"
local c_green = "\27[32m"
local c_yellow = "\27[33m"
local c_cyan = "\27[36m"
local c_reset = "\27[0m"

-- ==========================================
-- 1. BASE CLASS: WILLENSERKLÄRUNG
-- ==========================================
local function CreateWillenserklaerung(declaration_text, handlung, erklaerung, geschaeft, format_type)
    local private_state = {
        Handlungswille = handlung,
        Erklaerungsbewusstsein = erklaerung,
        Geschaeftswille = geschaeft
    }
    local public_api = {
        declaration = declaration_text,
        format = format_type or "paper_with_wet_signature"
    }

    function public_api:FireEvent()
        if not private_state.Handlungswille then
            error(c_red .. "[FATAL BGB EXCEPTION]: Kein Handlungswille! Input rejected (Reflex/Sleep)." .. c_reset)
        end
        if self.format == "whatsapp" or self.format == "email" then
            error(c_red .. "[SYNTAX ERROR § 623]: Electronic form excluded. Wet ink required." .. c_reset)
        end
        if not private_state.Erklaerungsbewusstsein then
            print(c_yellow .. "[WARNING]: Missing Erklärungsbewusstsein! Vulnerable to Anfechtung." .. c_reset)
            return true
        end
        print(c_green .. "[SUCCESS]: Perfect Willenserklärung compiled." .. c_reset)
        return true
    end

    local proxy = {}
    setmetatable(proxy, {
        __index = public_api,
        __newindex = function() error("[ACCESS DENIED]: Cannot alter internal BGB attributes!") end
    })
    return proxy
end

-- ==========================================
-- 2. ENGINE CLASSES: CONTRACTS
-- ==========================================
local Dienstvertrag = {}
Dienstvertrag.__index = Dienstvertrag

local Arbeitsvertrag = setmetatable({}, {__index = Dienstvertrag})
Arbeitsvertrag.__index = Arbeitsvertrag

function Arbeitsvertrag.new(years_tenure, in_probation, is_azubi)
    local self = setmetatable({}, Arbeitsvertrag)
    self.tenure = years_tenure
    self.in_probation = in_probation
    self.is_azubi = is_azubi
    self.isActive = true
    return self
end

function Arbeitsvertrag:CalculateNoticePeriod(initiator)
    if self.in_probation then return "2 Weeks (Any day) - § 622 Abs. 3" end
    if initiator == "Employee" then return "4 Weeks (to the 15th or end of month) - § 622 Abs. 1" end
    
    if self.tenure >= 20 then return "7 Months to end of month" end
    if self.tenure >= 15 then return "6 Months to end of month" end
    if self.tenure >= 12 then return "5 Months to end of month" end
    if self.tenure >= 10 then return "4 Months to end of month" end
    if self.tenure >= 8  then return "3 Months to end of month" end
    if self.tenure >= 5  then return "2 Months to end of month" end
    if self.tenure >= 2  then return "1 Month to end of month" end
    
    return "4 Weeks (to the 15th or end of month)"
end

-- ==========================================
-- 3. THE TRILOGY OF EXITS
-- ==========================================
function Arbeitsvertrag:OrdentlicheKuendigung(input_event, initiator)
    print(c_cyan .. "\n--- INITIATING: Ordentliche Kündigung (§ 622) ---" .. c_reset)
    if self.is_azubi and not self.in_probation and initiator == "Employer" then
        return print(c_red .. "[BLOCKED § 22 BBiG]: Azubi Invincibility Frames active. Cannot use Ordentliche Kündigung." .. c_reset)
    end
    
    local success, err = pcall(function() input_event:FireEvent() end)
    if not success then return print(err) end
    
    local cooldown = self:CalculateNoticePeriod(initiator)
    print("[SYSTEM] Unilateral termination accepted.")
    print(c_yellow .. "[SYSTEM] Applying Cooldown Timer: " .. cooldown .. c_reset)
    self.isActive = false
end

function Arbeitsvertrag:AusserordentlicheKuendigung(input_event, damage_check_passed, days_since_incident)
    print(c_cyan .. "\n--- INITIATING: The Hard Reset (§ 626 BGB) ---" .. c_reset)
    local success, err = pcall(function() input_event:FireEvent() end)
    if not success then return print(err) end
    
    if days_since_incident > 14 then
        return print(c_red .. "[BLOCKED]: The 14-day action window expired. Fallback to standard cooldown." .. c_reset)
    end
    if not damage_check_passed then
        return print(c_red .. "[BLOCKED]: Damage check failed (Zumutbarkeit). Must use standard cooldown." .. c_reset)
    end
    
    print(c_green .. "[SYSTEM] Damage check passed. Bypassing timers. Contract destroyed instantly." .. c_reset)
    self.isActive = false
end

function Arbeitsvertrag:Aufhebungsvertrag()
    print(c_cyan .. "\n--- INITIATING: Aufhebungsvertrag (The Negotiated Surrender) ---" .. c_reset)
    print(c_green .. "[SYSTEM] Bilateral handshake confirmed. Bypassing BGB cooldown logic." .. c_reset)
    print(c_yellow .. "[DEBUFF APPLIED] Employee afflicted with 12-week Arbeitsamt Sperrzeit." .. c_reset)
    self.isActive = false
end

-- ==========================================
-- 4. INTERACTIVE TERMINAL APP
-- ==========================================
local function ClearScreen()
    os.execute(package.config:sub(1,1) == "\\" and "cls" or "clear")
end

local function PrintMenu()
    print(c_cyan .. "==================================================")
    print("  ULTIMA PLATIN - BGB TERMINAL COMPANION")
    print("==================================================" .. c_reset)
    print("1. Read Speaker Notes (By Slide)")
    print("2. RUN SIMULATION: Standard Firing (Ordentlich)")
    print("3. RUN SIMULATION: The Emmely Boss Fight (Hard Reset)")
    print("4. RUN SIMULATION: The Azubi Trap")
    print("5. RUN SIMULATION: The Angry WhatsApp (Validation Check)")
    print("6. RUN SIMULATION: The Mutual Surrender")
    print("0. Exit Terminal")
    print(c_cyan .. "==================================================" .. c_reset)
    io.write("Select an option: ")
end

local function RunSimulations(choice)
    if choice == "2" then
        local emp = Arbeitsvertrag.new(12, false, false)
        local event = CreateWillenserklaerung("Written Notice", true, true, true, "paper_with_wet_signature")
        emp:OrdentlicheKuendigung(event, "Employer")
        
    elseif choice == "3" then
        local emp = Arbeitsvertrag.new(31, false, false)
        local event = CreateWillenserklaerung("Written Notice", true, true, true, "paper_with_wet_signature")
        print(">> SCENARIO: Cashier redeemed 1.30€ deposit receipt after 31 years of service.")
        emp:AusserordentlicheKuendigung(event, false, 5) -- Damage check fails
        
    elseif choice == "4" then
        local azubi = Arbeitsvertrag.new(1, false, true)
        local event = CreateWillenserklaerung("Written Notice", true, true, true, "paper_with_wet_signature")
        print(">> SCENARIO: Employer tries to fire an Apprentice after probation.")
        azubi:OrdentlicheKuendigung(event, "Employer")
        
    elseif choice == "5" then
        local emp = Arbeitsvertrag.new(2, false, false)
        local event = CreateWillenserklaerung("Angry Text Message", true, true, true, "whatsapp")
        print(">> SCENARIO: Boss fires employee via WhatsApp.")
        emp:OrdentlicheKuendigung(event, "Employer")
        
    elseif choice == "6" then
        local emp = Arbeitsvertrag.new(5, false, false)
        emp:Aufhebungsvertrag()
    end
    print("\nPress ENTER to continue...")
    io.read()
end

local function ShowNotes()
    ClearScreen()
    print(c_cyan .. "--- SPEAKER NOTES ---" .. c_reset)
    print("SLIDE 1-2: Open with Dante's Inferno. The 'path that does not stray' is the infinite loop of an unbefristeter Vertrag. We must enter § 620 to break it.")
    print("SLIDE 3:   Drop the 'Nerd Defense'. Ordentlich is Unilateral (One-sided button press). Aufhebungsvertrag is Bilateral (Handshake).")
    print("SLIDE 4:   Explain Tenure Armor. The state protects veterans. Max level is 7 months.")
    print("SLIDE 5-8: The Hard Reset. Explain the two fail-safes: The 14-Day Timer (strict window) and the Damage Check (Zumutbarkeit).")
    print("SLIDE 9:   The Azubi Armor. § 22 BBiG grants invincibility frames against ordinary termination.")
    print("SLIDE 10-11: Emmely Boss Fight. 31 years of trust cannot be one-shot by 1.30€. They failed the Damage Check.")
    print("SLIDE 12:  Post-Game. § 629 (Job Hunt Time) and § 630 (The Zeugnis Log File).")
    print("\nPress ENTER to return to menu...")
    io.read()
end

-- MAIN LOOP
while true do
    ClearScreen()
    PrintMenu()
    local choice = io.read()
    
    if choice == "0" then
        print("Logging off...")
        break
    elseif choice == "1" then
        ShowNotes()
    elseif choice >= "2" and choice <= "6" then
        ClearScreen()
        RunSimulations(choice)
    end
end
