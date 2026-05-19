local function CreateWillenserklaerung(declaration_text, handlung, erklaerung, geschaeft)
local private_state = {
Handlungswille = handlung or false,
Erklaerungsbewusstsein = erklaerung or false,
Geschaeftswille = geschaeft or false
}
local public_api = {
declaration = declaration_text or ""
}
function public_api:FireEvent()
if not private_state.Handlungswille then
error("[FATAL BGB EXCEPTION]: Kein Handlungswille! Input rejected (Reflex, Sleep, or Physical Force).")
end
if not private_state.Erklaerungsbewusstsein then
print("[WARNING]: Missing Erklärungsbewusstsein! Event compiled, but vulnerable to rollback (Anfechtung § 119 BGB).")
print(" >> Executing public action: " .. self.declaration)
return
end
if not private_state.Geschaeftswille then
print("[INFO]: Missing Geschäftswille. Contract active, but minor rollback possible.")
print(" >> Executing public action: " .. self.declaration)
return
end
print("[SUCCESS]: Perfect Willenserklärung. Executing: " .. self.declaration)
end
local proxy = {}
setmetatable(proxy, {
__index = public_api,
__newindex = function(table, key, value)
if key == "declaration" then
public_api.declaration = value
else
error("[ACCESS DENIED]: You cannot forcibly alter internal BGB mental attributes from the outside!")
end
end,
__tostring = function()
local status = private_state.Handlungswille and "Active" or "Void"
return "[BGB Object: Willenserklärung | Status: " .. status .. "]"
end
})
return proxy
end
return CreateWillenserklaerung
