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

-- Usage Example
math.randomseed(os.time())
local problem = Subnet.generate_problem()

print(string.format("Target: %s/%d", problem.ip, problem.cidr))
print(string.format("%-15s %s", "Mask:", problem.mask))
print(string.format("%-15s %s", "Network:", problem.network))
print(string.format("%-15s %s", "First Host:", problem.first_host))
print(string.format("%-15s %s", "Last Host:", problem.last_host))
print(string.format("%-15s %s", "Broadcast:", problem.broadcast))
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
local ip1, cidr1 = "192.168.178.28", 28
local ip2, cidr2 = "192.168.178.34", 26

print(string.format("Host A: %s/%d", ip1, cidr1))
print(string.format("Host B: %s/%d", ip2, cidr2))
print("Routing State: " .. Subnet.check_reachability(ip1, cidr1, ip2, cidr2))
-- Append to baseline main.lua to verify overlapping subset condition

local test_ipA, test_cidrA = "192.168.1.5", 24
local test_ipB, test_cidrB = "192.168.1.10", 28

print("--- OVERLAPPING SUBNET PROOF ---")
print(string.format("Host A: %s/%d", test_ipA, test_cidrA))
print(string.format("Host B: %s/%d", test_ipB, test_cidrB))

-- Execution trace:
-- A (192.168.1.5) applies /24 mask to B (192.168.1.10) -> Net 192.168.1.0. Matches A's net.
-- B (192.168.1.10) applies /28 mask to A (192.168.1.5) -> Net 192.168.1.0. Matches B's net.
print("Routing State: " .. Subnet.check_reachability(test_ipA, test_cidrA, test_ipB, test_cidrB))
