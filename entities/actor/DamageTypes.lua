DamageTypes = {
  PHYSICAL = 1,
  MAGIC = 2,
}

local DamageTypes_rev = {}
DamageTypes_rev[1] = "PHYSICAL"
DamageTypes_rev[2] = "MAGIC"

function DamageTypes.tostring(dtype)
  return DamageTypes_rev[dtype]
end