# TODO: Interprete 57 instructions into binary

local placeholder=function (id)
  return id
end

local interprete=function (instr, opts)
  local interpreted = {}
  for k, v in pairs(instr) do
    if type(v) == "function" then
      interpreted[k] = v(opts[k])
    else
      interpreted[k] = v
    end

    assert(type(interpreted[k]) == 'string', "Cannot interprete.")
  end

  return interpreted
end

local function to_string(i)
  local b = i.op .. i.rs .. i.rt .. i.rd .. i.shamt .. i.func
  assert(string.len(b) == 32, "Instruction's length should be 32")
  return b
end


local instructions = {
  add = { -- add
    op='000000',
    rs=placeholder,
    rt=placeholder,
    rd=placeholder,
    shamt='00000',
    func='100000',
  },
  addu = {
    op='000000',
    rs=placeholder,
    rt=placeholder,
    rd=placeholder,
    shamt='00000',
    func='100001',
  },
  sub={
    op='000000',
    rs=placeholder,
    rt=placeholder,
    rd=placeholder,
    shamt='00000',
    func='100010',
  },
  subu={
    op='000000',
    rs=placeholder,
    rt=placeholder,
    rd=placeholder,
    shamt='00000',
    func='100011',
  },
  and = {
    op='000000',
    rs=placeholder,
    rt=placeholder,
    rd=placeholder,
    shamt='00000',
    func='100011',
  }

}

print(to_string(interprete(instructions.add, {rs='00000', rt='00001', rd='00010'})))
