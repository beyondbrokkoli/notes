-- =====================================================================
--   Subnet Calc Pro v2.0
--   Interactive Hybrid Calculator & Exam Terminal
-- =====================================================================

local Subnet = {}

-- --- 1. CORE ENGINE ---
local function ip2bin(ip_str)
    local a, b, c, d = ip_str:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")
    if not a then return 0 end
    return (tonumber(a) << 24) | (tonumber(b) << 16) | (tonumber(c) << 8) | tonumber(d)
end

local function bin2ip(bin)
    return string.format("%d.%d.%d.%d", (bin >> 24) & 0xFF, (bin >> 16) & 0xFF, (bin >> 8) & 0xFF, bin & 0xFF)
end

local function cidr2mask(cidr)
    return ~((1 << (32 - cidr)) - 1) & 0xFFFFFFFF
end

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

function Subnet.generate_problem()
    local class = math.random(0, 2)
    local oct1, cidr
    if class == 0 then
        oct1, cidr = math.random(1, 126), math.random(8, 29)
    elseif class == 1 then
        oct1, cidr = math.random(128, 191), math.random(16, 29)
    else
        oct1, cidr = math.random(192, 223), math.random(24, 29)
    end
    return Subnet.calculate(string.format("%d.%d.%d.%d", oct1, math.random(0, 255), math.random(0, 255), math.random(0, 255)), cidr)
end

-- --- 2. TUI HELPER FUNCTIONS ---
local function clear_screen()
    os.execute("clear")
end

local function print_banner()
    print([[
=========================================================
   ___       _                 _    _   __
  / __\_   _| |__  _ __   ___ | |_ / | / /
  \__ \ | | | '_ \| '_ \ / _ \| __|| |/ / 
  ___) | |_| | |_) | | | |  __/ |_ | | /_ 
 |____/ \__,_|_.__/|_| |_|\___|\__||_|(_) 
       HYBRID SUBNET CALCULATOR & EXAM TERMINAL
=========================================================
    ]])
end

local function get_input(prompt)
    io.write(prompt)
    local input = io.read()
    return input and input:match("^%s*(.-)%s*$") or ""
end

-- --- 3. HYBRID INTERACTIVE WORKFLOW ---
local function run_challenge(custom_ip, custom_cidr)
    local result = (custom_ip and custom_cidr) and Subnet.calculate(custom_ip, custom_cidr) or Subnet.generate_problem()

    clear_screen()
    print_banner()
    print(string.format("  TARGET IP : %s / %d", result.ip, result.cidr))
    print(string.format("  SUBNET MASK : %s", result.mask))
    print("---------------------------------------------------------")
    print("  [INSTRUCTION] Enter the correct IP for each field.")
    print("  [HINT]        Leave blank and press Enter to SHOW answer.")
    print("=========================================================\n")

    local fields = {
        { label = "Network",    key = "network" },
        { label = "First Host", key = "first_host" },
        { label = "Last Host",  key = "last_host" },
        { label = "Broadcast",  key = "broadcast" }
    }

    local score = 0
    for _, f in ipairs(fields) do
        local user_ans = get_input(string.format("  %-12s : ", f.label))
        local correct_ans = result[f.key]

        if user_ans == correct_ans then
            print(string.format("  -> [ OK ] Correct!\n"))
            score = score + 1
        elseif user_ans == "" then
            print(string.format("  -> [SHOW] %s\n", correct_ans))
        else
            print(string.format("  -> [FAIL] Expected: %s\n", correct_ans))
        end
    end

    print("=========================================================")
    print(string.format("  FINAL SCORE : %d / 4", score))
    print("=========================================================")
    get_input("\n  Press Enter to return to main menu...")
end

-- --- 4. MAIN LOOP ---
math.randomseed(os.time())

while true do
    clear_screen()
    print_banner()
    print("  [1] Custom Target (Input IP/CIDR -> Enter Exam)")
    print("  [2] Random Target (Auto-Generate -> Enter Exam)")
    print("  [3] Exit")
    print("=========================================================")

    local choice = get_input("  Select mode (1-3): ")

    if choice == "1" then
        print("---------------------------------------------------------")
        local ip = get_input("  Enter Target IP (e.g., 192.168.1.50) : ")
        local cidr = tonumber(get_input("  Enter Target CIDR (e.g., 24)         : "))
        if ip:match("%d+%.%d+%.%d+%.%d+") and cidr and cidr >= 0 and cidr <= 32 then
            run_challenge(ip, cidr)
        else
            print("  [ERROR] Invalid IP or CIDR.")
            get_input("  Press Enter to continue...")
        end
    elseif choice == "2" then
        run_challenge()
    elseif choice == "3" then
        clear_screen()
        os.exit(0)
    end
end
