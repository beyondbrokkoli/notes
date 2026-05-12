-- Lua 5.3+ Subnet Engine (Requires native bitwise operators)
local Subnet = {}

-- Convert dotted-decimal to 32-bit integer
local function ip2bin(ip_str)
    local a, b, c, d = ip_str:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")
    return (tonumber(a) << 24) | (tonumber(b) << 16) | (tonumber(c) << 8) | tonumber(d)
end

-- Convert 32-bit integer to dotted-decimal
local function bin2ip(bin)
    return string.format("%d.%d.%d.%d",
        (bin >> 24) & 0xFF,
        (bin >> 16) & 0xFF,
        (bin >> 8) & 0xFF,
        bin & 0xFF)
end

-- Generate 32-bit mask from CIDR prefix
local function cidr2mask(cidr)
    return ~((1 << (32 - cidr)) - 1) & 0xFFFFFFFF
end

-- Core calculation engine
function Subnet.calculate(ip_str, cidr)
    local ip = ip2bin(ip_str)
    local mask = cidr2mask(cidr)

    local network = ip & mask
    local broadcast = ip | (~mask & 0xFFFFFFFF)

    return {
        ip         = ip_str,
        cidr       = cidr,
        mask       = bin2ip(mask),
        network    = bin2ip(network),
        first_host = bin2ip(network + 1),
        last_host  = bin2ip(broadcast - 1),
        broadcast  = bin2ip(broadcast)
    }
end

-- Problem generator mirroring original JS class-based constraints
function Subnet.generate_problem()
    local class = math.random(0, 2)
    local oct1, cidr

    if class == 0 then     -- Class A
        oct1 = math.random(1, 126)
        cidr = math.random(8, 29)
    elseif class == 1 then -- Class B
        oct1 = math.random(128, 191)
        cidr = math.random(16, 29)
    else                   -- Class C
        oct1 = math.random(192, 223)
        cidr = math.random(24, 29)
    end

    local ip = string.format("%d.%d.%d.%d",
        oct1, math.random(0, 255), math.random(0, 255), math.random(0, 255))

    return Subnet.calculate(ip, cidr)
end

-- Hole Werte aus den Startargumenten oder nutze Fallbacks
--local target_ip = arg[1]
--local target_cidr = tonumber(arg[2])

--if not target_ip or not target_cidr then
--    print("Usage: lua ip_calculator.lua <IP> <CIDR>")
--    print("Example: lua ip_calculator.lua 192.168.178.28 28")
--    os.exit(1)
--end

-- Berechnung ausführen
--local result = Subnet.calculate(target_ip, target_cidr)

-- Ausgabe formatieren
--print(string.format("Target: %s/%d", result.ip, result.cidr))
--print("-----------------------------------------")
--print(string.format("%-15s %s", "Mask:", result.mask))
--print(string.format("%-15s %s", "Network:", result.network))
--print(string.format("%-15s %s", "First Host:", result.first_host))
--print(string.format("%-15s %s", "Last Host:", result.last_host))
--print(string.format("%-15s %s", "Broadcast:", result.broadcast))
-- Append to baseline main.lua

-- Evaluates Layer 2 vs Layer 3 reachability perspective for both hosts
function Subnet.check_reachability(ipA_str, cidrA, ipB_str, cidrB)
    local ipA, maskA = ip2bin(ipA_str), cidr2mask(cidrA)
    local ipB, maskB = ip2bin(ipB_str), cidr2mask(cidrB)

    local netA = ipA & maskA
    local netB = ipB & maskB

    -- Bitwise check: Does Host B's IP fall inside Host A's network boundary?
    local a_sees_b_local = (ipB & maskA) == netA
    -- Bitwise check: Does Host A's IP fall inside Host B's network boundary?
    local b_sees_a_local = (ipA & maskB) == netB

    if a_sees_b_local and b_sees_a_local then
        return "Symmetric (Local L2)"
    elseif not a_sees_b_local and not b_sees_a_local then
        return "Symmetric (Routed L3)"
    elseif a_sees_b_local then
        return "Asymmetric Loophole (A->B Local L2, B->A Routed L3)"
    else
        return "Asymmetric Loophole (B->A Local L2, A->B Routed L3)"
    end
end

-- Implementation test matching the specified failure domain
--local ip1, cidr1 = "192.168.178.28", 28
--local ip2, cidr2 = "192.168.178.34", 26

--print(string.format("Host A: %s/%d", ip1, cidr1))
--print(string.format("Host B: %s/%d", ip2, cidr2))
--print("Routing State: " .. Subnet.check_reachability(ip1, cidr1, ip2, cidr2))
-- Append to baseline main.lua to verify overlapping subset condition

--local test_ipA, test_cidrA = "192.168.1.5", 24
--local test_ipB, test_cidrB = "192.168.1.10", 28

--print("--- OVERLAPPING SUBNET PROOF ---")
--print(string.format("Host A: %s/%d", test_ipA, test_cidrA))
--print(string.format("Host B: %s/%d", test_ipB, test_cidrB))

-- Execution trace:
-- A (192.168.1.5) applies /24 mask to B (192.168.1.10) -> Net 192.168.1.0. Matches A's net.
-- B (192.168.1.10) applies /28 mask to A (192.168.1.5) -> Net 192.168.1.0. Matches B's net.
--print("Routing State: " .. Subnet.check_reachability(test_ipA, test_cidrA, test_ipB, test_cidrB))
-- Replace the execution block at the bottom of main.lua with this interactive TUI

-- --- UI HELPER FUNCTIONS ---
local function clear_screen()
    os.execute("clear") -- use "cls" for Windows
end

local function get_input(prompt)
    io.write(prompt)
    local input = io.read()
    return input and input:match("^%s*(.-)%s*$") or ""
end

-- --- PRACTICE MODE (Restored HTML App Functionality) ---
local function practice_mode()
    clear_screen()
    print("=========================================")
    print("         SUBNET PRACTICE MODE            ")
    print("=========================================\n")

    local problem = Subnet.generate_problem()
    print(string.format("Target: %s/%d", problem.ip, problem.cidr))
    print(string.format("Mask:   %s\n", problem.mask))

    local user_answers = {
        network    = get_input("Enter Network:    "),
        first_host = get_input("Enter First Host: "),
        last_host  = get_input("Enter Last Host:  "),
        broadcast  = get_input("Enter Broadcast:  ")
    }

    print("\n--- RESULTS ---")
    local function verify(label, user_val, real_val)
        local status = (user_val == real_val) and "[OK]" or "[FAIL]"
        print(string.format("%-6s %-15s (Expected: %s)", status, label .. ":", real_val))
    end

    verify("Network", user_answers.network, problem.network)
    verify("First Host", user_answers.first_host, problem.first_host)
    verify("Last Host", user_answers.last_host, problem.last_host)
    verify("Broadcast", user_answers.broadcast, problem.broadcast)

    get_input("\nPress Enter to continue...")
end

-- --- CALCULATOR MODE ---
local function calc_mode(ip, cidr)
    local result = Subnet.calculate(ip, cidr)
    print("\n--- CALCULATOR RESULTS ---")
    print(string.format("Target: %s/%d", result.ip, result.cidr))
    print(string.format("%-15s %s", "Mask:", result.mask))
    print(string.format("%-15s %s", "Network:", result.network))
    print(string.format("%-15s %s", "First Host:", result.first_host))
    print(string.format("%-15s %s", "Last Host:", result.last_host))
    print(string.format("%-15s %s", "Broadcast:", result.broadcast))
    get_input("\nPress Enter to continue...")
end

-- --- MAIN ENTRY POINT ---
if arg[1] and arg[2] then
    -- CLI execution bypasses menu
    calc_mode(arg[1], tonumber(arg[2]))
    os.exit(0)
end

-- Interactive Menu Loop
while true do
    clear_screen()
    print("=========================================")
    print("       IP SUBNET ENGINE v2.0             ")
    print("=========================================")
    print("  [1] Interactive Calculator")
    print("  [2] Practice Mode (Quiz)")
    print("  [3] Run Asymmetric Loophole Proofs")
    print("  [4] Exit")
    print("=========================================")

    local choice = get_input("Select mode (1-4): ")

    if choice == "1" then
        local ip = get_input("Enter IP (e.g., 192.168.1.1): ")
        local cidr = tonumber(get_input("Enter CIDR (e.g., 24): "))
        if ip ~= "" and cidr then calc_mode(ip, cidr) end
    elseif choice == "2" then
        practice_mode()
    elseif choice == "3" then
        clear_screen()
        print("--- ROUTING DIAGNOSTICS ---")
        print("Test 1: Mismatched Masks (Different Scopes)")
        print(Subnet.check_reachability("192.168.178.28", 28, "192.168.178.34", 26))
        print("\nTest 2: Mismatched Masks (Overlapping Scopes)")
        print(Subnet.check_reachability("192.168.1.5", 24, "192.168.1.10", 28))
        get_input("\nPress Enter to continue...")
    elseif choice == "4" then
        clear_screen()
        os.exit(0)
    end
end
