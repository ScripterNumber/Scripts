local valuetochange = "maxHookDist"
local valuetoset = 999999

for i,v in pairs(getgc(true)) do
if v and type(v) == 'table' and rawget(v, valuetochange) then
warn(valuetochange, "Finded")
rawset(v, valuetochange, valuetoset)
print(valuetochange, "was successfully setted to", valuetoset)
print(valuetochange, "value:", rawget(v, valuetochange))
end
end
