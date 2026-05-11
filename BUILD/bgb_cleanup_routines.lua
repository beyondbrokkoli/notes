local CleanupRoutines = {}
function CleanupRoutines.FristlosBeiVertrauen(is_employee, has_fixed_salary, is_untimely)
print("\n--- INITIATING: High Trust Bypass (§ 627) ---")
if is_employee then
return print("[BLOCKED]: Target is an Employee. § 627 bypass is disabled. Use § 626 instead.")
end
if has_fixed_salary then
return print("[BLOCKED]: Target has a permanent fixed salary. Bypass disabled.")
end
if is_untimely then
print("[WARNING]: Termination executed at an 'untimely' moment (zur Unzeit).")
print("[DEBUFF]: You are liable for resulting damages (Schadensersatz).")
else
print("[SUCCESS]: High Trust Bypass executed. Contract terminated instantly without 'Wichtiger Grund'.")
end
end
function CleanupRoutines.CalculateFinalPayout(who_caused_termination, services_rendered, interest_lost)
print("\n--- INITIATING: Damage Calculation (§ 628) ---")
local payout = 0
if who_caused_termination == "Initiator_Breach_Of_Contract" then
print("[CALCULATION]: Initiator caused the breach. They forfeit pay for services that are now useless to the victim.")
payout = services_rendered - interest_lost
payout = math.max(0, payout)
else
print("[CALCULATION]: Standard partial remuneration applies.")
payout = services_rendered
end
print("[SYSTEM]: Victim is also entitled to claim Schadensersatz (Damages) for the sudden contract death.")
return payout
end
function CleanupRoutines.ApplyJobHuntBuff(employee_requested)
print("\n--- INITIATING: Freizeit zur Stellungssuche (§ 629) ---")
if employee_requested then
print("[BUFF APPLIED]: Employer must grant 'reasonable paid time off' for job interviews.")
return true
else
print("[SYSTEM]: Buff dormant. Employee must actively request it.")
return false
end
end
function CleanupRoutines.GenerateAchievementLog(employee_requested, request_type)
print("\n--- INITIATING: Pflicht zur Zeugniserteilung (§ 630 / § 109 GewO) ---")
if not employee_requested then
return print("[SYSTEM]: No log file generated. Must be explicitly requested.")
end
if request_type == "einfach" then
print("[FILE GENERATED]: Einfaches Zeugnis (Simple Log).")
print(" -> Contents: Dates of employment and factual list of tasks.")
elseif request_type == "qualifiziert" then
print("[FILE GENERATED]: Qualifiziertes Zeugnis (Advanced Log).")
print(" -> Contents: Tasks + Evaluation of performance and social conduct.")
end
print("[FORMAT REQUIREMENT]: Must be written. Electronic format (PDF/Email) only allowed if employee explicitly consents!")
end
CleanupRoutines.ApplyJobHuntBuff(true)
CleanupRoutines.GenerateAchievementLog(true, "qualifiziert")
CleanupRoutines.FristlosBeiVertrauen(false, false, false)
