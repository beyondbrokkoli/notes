-- ======================================================================
-- SUBNETTING GORE -> ASCII SLIDESHOW
-- Requires: Lua 5.3 or higher (for native bitwise operators: &, |, ~)
-- ======================================================================

-- Helper to clear the screen (works on Windows/Linux/Mac)
local function clear_screen()
    os.execute(package.config:sub(1,1) == '\\' and 'cls' or 'clear')
end

-- Helper for the slide deck pause
local function wait_for_enter()
    print("\n   >>> Press [ENTER] to continue, or [CTRL+C] to quit <<<")
    io.read()
end

-- Print a nice ASCII border
local function print_header(title)
    clear_screen()
    print("================================================================")
    print("  " .. string.upper(title))
    print("================================================================")
    print()
end

-- Helper to convert an IP string to a 32-bit integer
local function ip_to_int(ip)
    local o1, o2, o3, o4 = ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")
    -- Shift octets to their correct 32-bit positions
    return (tonumber(o1) << 24) | (tonumber(o2) << 16) | (tonumber(o3) << 8) | tonumber(o4)
end

-- Helper to convert a 32-bit integer back to an IP string
local function int_to_ip(int)
    local o1 = (int >> 24) & 0xFF
    local o2 = (int >> 16) & 0xFF
    local o3 = (int >> 8) & 0xFF
    local o4 = int & 0xFF
    return string.format("%d.%d.%d.%d", o1, o2, o3, o4)
end

-- ======================================================================
-- SLIDE DEFINITIONS
-- ======================================================================

local function slide_1_intro()
    print_header("Slide 1: The Magic of Bitwise Math")
    print("  To understand subnetting, computers don't look at decimals.")
    print("  They look at 1s and 0s using Bitwise operations.\n")
    print("  [ THE RULES ]")
    print("  1. Find Net-ID   ->  IP_Address AND Subnet_Mask")
    print("  2. Find Bcast    ->  Net-ID OR (Inverted Subnet_Mask)\n")
    print("  Note on your text: The notes mentioned 'XNOR' for Broadcast.")
    print("  In standard code, we use an OR with a NOT mask (~Mask).")
    wait_for_enter()
end

local function slide_2_example_1()
    print_header("Slide 2: Example 1 - The Standard /24")
    
    local ip_str = "192.168.1.5"
    local mask_str = "255.255.255.0"
    
    local ip = ip_to_int(ip_str)
    local mask = ip_to_int(mask_str)
    
    -- MATH:
    local net_id = ip & mask
    local bcast = net_id | (~mask & 0xFFFFFFFF) -- 0xFFFFFFFF keeps it 32-bit safe
    
    print("  Given IP:   " .. ip_str)
    print("  Given Mask: " .. mask_str .. " (or /24)\n")
    print("  [ LIVE LUA CALCULATION ]")
    print("  Network ID: " .. int_to_ip(net_id) .. "  <-- (IP & Mask)")
    print("  First IP:   " .. int_to_ip(net_id + 1))
    print("  Last IP:    " .. int_to_ip(bcast - 1))
    print("  Broadcast:  " .. int_to_ip(bcast) .. "  <-- (Net-ID | ~Mask)")
    
    wait_for_enter()
end

local function slide_3_example_2()
    print_header("Slide 3: Example 2 - The Tricky /27")
    
    local ip_str = "130.95.122.195"
    local mask_str = "255.255.255.224"
    
    local ip = ip_to_int(ip_str)
    local mask = ip_to_int(mask_str)
    
    local net_id = ip & mask
    local bcast = net_id | (~mask & 0xFFFFFFFF)
    
    print("  Given IP:   " .. ip_str)
    print("  Given Mask: " .. mask_str .. " (or /27)\n")
    
    print("  [ THE JUMP METHOD (Lösungsweg 2) ]")
    print("  256 - 224 = 32 (This is your jump/Sprungweite!)")
    print("  195 / 32  = 6.09 (Round down to 6)")
    print("  6 * 32    = 192 (This is the 4th octet of your Net-ID)\n")
    
    print("  [ LIVE LUA CALCULATION ]")
    print("  Network ID: " .. int_to_ip(net_id))
    print("  First IP:   " .. int_to_ip(net_id + 1))
    print("  Last IP:    " .. int_to_ip(bcast - 1))
    print("  Broadcast:  " .. int_to_ip(bcast))
    print("  Usable Hosts: " .. tostring((bcast - 1) - (net_id + 1) + 1))
    
    wait_for_enter()
end

local function slide_4_exam_question()
    print_header("Slide 4: Typical Exam Question - Can they ping?")
    
    local pc1_ip = "128.125.72.28"
    local pc2_ip = "128.125.72.34"
    -- The notes used a jump of 16, which implies a mask of 256-16 = 240 (/28)
    local mask = ip_to_int("255.255.255.240")
    
    local net1 = ip_to_int(pc1_ip) & mask
    local net2 = ip_to_int(pc2_ip) & mask
    
    print("  PC 1: " .. pc1_ip)
    print("  PC 2: " .. pc2_ip)
    print("  Mask: 255.255.255.240 (Jump of 16)\n")
    
    print("  Let's calculate their Network IDs using bitwise AND:")
    print("  PC 1 Net-ID: " .. int_to_ip(net1))
    print("  PC 2 Net-ID: " .. int_to_ip(net2) .. "\n")
    
    if net1 == net2 then
        print("  [ VERDICT ] -> YES! They are on the same subnet.")
    else
        print("  [ VERDICT ] -> NO! Different subnets. The router steps in.")
        print("  Even though .28 and .34 are close, the /28 fence sits")
        print("  right at .31 (PC 1's broadcast) and .32 (PC 2's Net-ID).")
    end
    
    print("\n================================================================")
    print("  END OF DECODED GORE PRESENTATION")
    print("================================================================\n")
end

-- ======================================================================
-- MAIN EXECUTION
-- ======================================================================
slide_1_intro()
slide_2_example_1()
slide_3_example_2()
slide_4_exam_question()
