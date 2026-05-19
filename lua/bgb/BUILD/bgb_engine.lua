local CreateWillenserklaerung = require("class_willenserklaerung")
local Dienstvertrag = {}
Dienstvertrag.__index = Dienstvertrag
function Dienstvertrag.new(payment_frequency)
local self = setmetatable({}, Dienstvertrag)
self.payment_frequency = payment_frequency
self.isActive = true
return self
end
function Dienstvertrag:CalculateNoticePeriod()
if self.payment_frequency == "daily" then return "1 Day (Ablauf des folgenden Tages)" end
if self.payment_frequency == "weekly" then return "1 Week (Ablauf des folgenden Sonnabends)" end
if self.payment_frequency == "monthly" then return "15th of the month to the end of the month" end
return "Anytime (§ 621 Nr. 5)"
end
local Arbeitsvertrag = setmetatable({}, {__index = Dienstvertrag})
Arbeitsvertrag.__index = Arbeitsvertrag
function Arbeitsvertrag.new(years_tenure, in_probation)
local self = setmetatable(Dienstvertrag.new("monthly"), Arbeitsvertrag)
self.tenure = years_tenure
self.in_probation = in_probation
return self
end
function Arbeitsvertrag:CalculateNoticePeriod(initiator)
if self.in_probation then
return "2 Weeks (Any day) - § 622 Abs. 3"
end
if initiator == "Employee" then
return "4 Weeks (to the 15th or end of month) - § 622 Abs. 1"
end
if self.tenure >= 20 then return "7 Months to end of month" end
if self.tenure >= 15 then return "6 Months to end of month" end
if self.tenure >= 12 then return "5 Months to end of month" end
if self.tenure >= 10 then return "4 Months to end of month" end
if self.tenure >= 8  then return "3 Months to end of month" end
if self.tenure >= 5  then return "2 Months to end of month" end
if self.tenure >= 2  then return "1 Month to end of month" end
return "4 Weeks (to the 15th or end of month)"
end
function Arbeitsvertrag:OrdentlicheKuendigung(input_event, initiator)
print("\n--- INITIATING: Ordentliche Kündigung (§ 622) ---")
input_event:FireEvent()
local cooldown = self:CalculateNoticePeriod(initiator)
print("[SYSTEM] Unilateral termination accepted.")
print("[SYSTEM] Applying Cooldown Timer: " .. cooldown)
self.isActive = false
end
function Arbeitsvertrag:AusserordentlicheKuendigung(input_event, damage_check_passed)
print("\n--- INITIATING: Außerordentliche Kündigung (§ 626) THE HARD RESET ---")
input_event:FireEvent()
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
local veteran_employee = Arbeitsvertrag.new(16, false)
local valid_input = CreateWillenserklaerung("Written Notice of Termination", true, true, true)
veteran_employee:OrdentlicheKuendigung(valid_input, "Employer")
print("\n--- FLOW 2: The Sleepwalker Bug ---")
local sleepwalker_input = CreateWillenserklaerung("Sleepwalking termination", false, false, false)
local success, err = pcall(function()
veteran_employee:AusserordentlicheKuendigung(sleepwalker_input, true)
end)
if not success then
print("[ARBEITSGERICHT RULING]: Termination voided -> " .. err)
end
