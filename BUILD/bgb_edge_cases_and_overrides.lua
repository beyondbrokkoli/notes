local function ValidateFormat(format_type)
print(">> Validating Input Format (§ 623 BGB)...")
if format_type == "whatsapp" or format_type == "email" or format_type == "pdf_scan" then
error("[SYNTAX ERROR § 623]: Electronic form strictly excluded. Wet ink on paper required. Event void.")
elseif format_type == "verbal" then
error("[SYNTAX ERROR § 623]: Verbal termination excluded. Wet ink on paper required. Event void.")
elseif format_type == "paper_with_wet_signature" then
print(">> [OK] Format validation passed. Analog signature detected.")
return true
end
return false
end
local EdgeCases = {}
function EdgeCases.CheckLifetimeArmor(contract_duration_years, years_worked)
if contract_duration_years > 5 or contract_duration_years == math.huge then
if years_worked >= 5 then
print("[OVERRIDE § 624]: Employee has served 5 years on a long-term contract.")
print("[SYSTEM]: Employee granted hardcoded exit option with 6-month cooldown.")
return true
end
end
return false
end
function EdgeCases.CheckImplicitExtension(is_contract_expired, is_employee_working, employer_knows, employer_objected)
if is_contract_expired and is_employee_working and employer_knows then
if not employer_objected then
print("[STATE MUTATION § 625]: Contract expired, but runtime execution continued without interruption.")
print("[SYSTEM]: Automatically mutating contract duration from 'Fixed' to 'Infinite'.")
return "unbefristet"
end
end
return "expired"
end
local function FristloseKuendigung(input_format, days_since_knowledge, damage_check_passed)
print("\n--- INITIATING: Emergency Override (§ 626 BGB) ---")
local success, err = pcall(ValidateFormat, input_format)
if not success then return print(err) end
print(">> Checking Time Limit (§ 626 Abs. 2)...")
if days_since_knowledge > 14 then
print("[BLOCKED]: The 14-day action window has expired.")
print("[SYSTEM]: The incident is wiped from the active cache. Fallback to standard cooldown required.")
return false
end
print(">> [OK] Timer check passed. Action taken within 14 days.")
print(">> Calculating 'Zumutbarkeit' (Reasonableness)...")
if not damage_check_passed then
print("[BLOCKED]: Damage check failed (Interessenabwägung).")
print("[SYSTEM]: It is legally reasonable to wait out the standard notice period.")
return false
end
print(">> [OK] Damage check passed. Severe breach of trust confirmed.")
print("\n[SUCCESS]: Emergency Override executed.")
print("[SYSTEM]: Bypassing all standard cooldowns. Contract pointer set to NULL immediately.")
return true
end
print("\n--- SCENARIO A: The Angry WhatsApp ---")
FristloseKuendigung("whatsapp", 2, true)
print("\n--- SCENARIO B: The Hesitant Boss ---")
FristloseKuendigung("paper_with_wet_signature", 21, true)
print("\n--- SCENARIO C: The Emmely Case (The 1.30€ Incident) ---")
FristloseKuendigung("paper_with_wet_signature", 5, false)
