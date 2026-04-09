-- 1. THE RAW INPUT (From our previous script)
local function CreateWillenserklaerung(intent_valid)
    return { isValid = intent_valid }
end
-- ==========================================
-- BASE CLASS: DIENSTVERTRAG (§ 611)
-- The generic service entity. Destructs via § 621.
-- ==========================================
local Dienstvertrag = {}
Dienstvertrag.__index = Dienstvertrag

function Dienstvertrag.new(payment_frequency)
    local self = setmetatable({}, Dienstvertrag)
    self.payment_frequency = payment_frequency
    -- "daily", "weekly", "monthly"
    self.isActive = true
    return self
end
-- The Default Destructor (§ 621)
function Dienstvertrag:CalculateNoticePeriod()
    if self.payment_frequency == "daily" then return "1 Day (Ablauf des folgenden Tages)" end
    if self.payment_frequency == "weekly" then return "1 Week (Ablauf des folgenden Sonnabends)" end
    if self.payment_frequency == "monthly" then return "15th of the month to the end of the month" end
    return "Anytime (§ 621 Nr. 5)"
end
-- ==========================================
-- DERIVED CLASS: ARBEITSVERTRAG (§ 611a)
-- Inherits from Dienstvertrag, but overrides the Destructor with § 622 Armor.
-- ==========================================
local Arbeitsvertrag = setmetatable({}, {__index = Dienstvertrag})
Arbeitsvertrag.__index = Arbeitsvertrag

function Arbeitsvertrag.new(years_tenure, in_probation)
    local self = setmetatable(Dienstvertrag.new("monthly"), Arbeitsvertrag)
    self.tenure = years_tenure
    self.in_probation = in_probation
    return self
end
-- OVERRIDDEN DESTRUCTOR (§ 622) - The Cooldown scaling logic
function Arbeitsvertrag:CalculateNoticePeriod(initiator)
    if self.in_probation then
        return "2 Weeks (Any day) - § 622 Abs. 3"
    end
    -- Employee quitting? Standard 4 weeks. (§ 622 Abs. 1)
    if initiator == "Employee" then
        return "4 Weeks (to the 15th or end of month) - § 622 Abs. 1"
    end
    -- Employer firing? Run the Tenure Armor check. (§ 622 Abs. 2)
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
-- THE TRILOGY (The 3 Destructor Flows)
-- ==========================================
function Arbeitsvertrag:OrdentlicheKuendigung(input_event, initiator)
    print("\n--- INITIATING: Ordentliche Kündigung (§ 622) ---")
    if not input_event.isValid then 
        return print("[ERROR] Invalid Willenserklärung. Kündigung failed.") 
    end
    
    local cooldown = self:CalculateNoticePeriod(initiator)
    print("[SYSTEM] Unilateral termination accepted.")
    print("[SYSTEM] Applying Cooldown Timer: " .. cooldown)
    self.isActive = false
end

function Arbeitsvertrag:AusserordentlicheKuendigung(input_event, damage_check_passed)
    print("\n--- INITIATING: Außerordentliche Kündigung (§ 626) THE NUKE ---")
    if not input_event.isValid then 
        return print("[ERROR] Invalid Willenserklärung.") 
    end
    
    if not damage_check_passed then
        return print("[BLOCKED] Wichtiger Grund (Damage Check) failed! Revert to Ordentliche Kündigung.")
    end
    
    print("[SYSTEM] Damage check passed. Bypassing § 622 timers.")
    print("[SYSTEM] Contract instantly destroyed.")
    self.isActive = false
end

function Arbeitsvertrag:Aufhebungsvertrag(employee_consent, employer_consent)
    print("\n--- INITIATING: Aufhebungsvertrag (The Negotiated Surrender) ---")
    if employee_consent and employer_consent then
        print("[SYSTEM] Bilateral handshake confirmed. Bypassing all BGB Kündigung logic.")
        print("[SYSTEM] Contract dissolved gracefully.")
        print("[DEBUFF APPLIED] Employee afflicted with 12-week Arbeitsamt Sperrzeit.")
        self.isActive = false
    else
        print("[ERROR] Missing consent from one party. Aufhebungsvertrag failed.")
    end
end
-- ==========================================
-- RUNTIME SIMULATION
-- ==========================================
-- Spawn a veteran employee (16 years tenure, no probation)
local veteran_employee = Arbeitsvertrag.new(16, false)
local valid_input = CreateWillenserklaerung(true)
-- FLOW 1: Standard Firing
veteran_employee:OrdentlicheKuendigung(valid_input, "Employer")
-- Output: Applying Cooldown Timer: 6 Months to end of month
-- FLOW 2: The Emmely Boss Fight (Trying to drop the Nuke for 1.30€)
veteran_employee = Arbeitsvertrag.new(31, false)
veteran_employee:AusserordentlicheKuendigung(valid_input, false)
-- Output: [BLOCKED] Damage check failed!
-- FLOW 3: The Golden Handshake
veteran_employee = Arbeitsvertrag.new(5, false)
veteran_employee:Aufhebungsvertrag(true, true)
-- Output: [DEBUFF APPLIED] 12-week Arbeitsamt Sperrzeit.
