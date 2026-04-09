-- ==========================================
-- MIDDLEWARE: THE FORMAT VALIDATOR (§ 623)
-- The BGB is an analog system. It rejects digital inputs.
-- ==========================================
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
-- ==========================================
-- EDGE CASES: THE IMPLICIT LOOPS (§ 624 & § 625)
-- ==========================================
local EdgeCases = {}
-- § 624: The Anti-Slavery Protocol (Contracts > 5 Years / Lifetime)
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
-- § 625: The Zombie Process (Stillschweigende Verlängerung)
-- What happens if the contract expires, but the employee just keeps working?
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
-- ==========================================
-- THE EMERGENCY OVERRIDE (§ 626)
-- Fristlose Kündigung aus wichtigem Grund
-- ==========================================
local function FristloseKuendigung(input_format, days_since_knowledge, damage_check_passed)
    print("\n--- INITIATING: Emergency Override (§ 626 BGB) ---")
    -- STEP 1: Strict Format Check (§ 623)
    local success, err = pcall(ValidateFormat, input_format)
    if not success then return print(err) end
    -- STEP 2: The 14-Day Timer (§ 626 Abs. 2)
    -- The system gives you exactly two weeks to trigger the override after an incident.
    print(">> Checking Time Limit (§ 626 Abs. 2)...")
    if days_since_knowledge > 14 then
        print("[BLOCKED]: The 14-day action window has expired.")
        print("[SYSTEM]: The incident is wiped from the active cache. Fallback to standard cooldown required.")
        return false
    end
    print(">> [OK] Timer check passed. Action taken within 14 days.")
    -- STEP 3: The Zumutbarkeit Check (§ 626 Abs. 1)
    -- The scale of interests: Is it mathematically unreasonable to keep them for 4 more weeks?
    print(">> Calculating 'Zumutbarkeit' (Reasonableness)...")
    if not damage_check_passed then
        print("[BLOCKED]: Damage check failed (Interessenabwägung).")
        print("[SYSTEM]: It is legally reasonable to wait out the standard notice period.")
        return false
    end
    print(">> [OK] Damage check passed. Severe breach of trust confirmed.")
    -- EXECUTION
    print("\n[SUCCESS]: Emergency Override executed.")
    print("[SYSTEM]: Bypassing all standard cooldowns. Contract pointer set to NULL immediately.")
    return true
end
-- ==========================================
-- RUNTIME SIMULATION (Your Presentation Notes)
-- ==========================================
print("\n--- SCENARIO A: The Angry WhatsApp ---")
FristloseKuendigung("whatsapp", 2, true)
-- Output crashes at ValidateFormat: Electronic form strictly excluded.
print("\n--- SCENARIO B: The Hesitant Boss ---")
-- Boss catches employee stealing, but waits 3 weeks to ask HR what to do.
FristloseKuendigung("paper_with_wet_signature", 21, true)
-- Output blocks at Timer Check: The 14-day window has expired.
print("\n--- SCENARIO C: The Emmely Case (The 1.30€ Incident) ---")
-- Format is paper, timer is within 14 days, but the damage check fails due to 31 years of loyalty.
FristloseKuendigung("paper_with_wet_signature", 5, false)
-- Output blocks at Zumutbarkeit: It is legally reasonable to wait out the standard notice period.
