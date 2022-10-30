#pragma once
#include <string>
#include <variant>

enum class Kind { kR, kI, kJ };

enum class RType : int {
  kAnd,
  kAndu,
  kSub,
  kSubu,
  kMult,
  kMultu,
  kDiv,
  kDivu,
  kMfhi,
  kMflo,
  kMthi,
  kMtlo,
  kMfc0,
  kMtc0,
  kOr,
  kXor,
  kNor,
  kSlt,
  kSltu,
  kSll,
  kSrl,
  kSra,
  kSllv,
  kSrlv,
  kSrav,
  kJr,
  kJalr,
  kBreak,
  kSyscall,
  kEret
};

enum class IType : int {
  kAddi,
  kAddiu,
  kAndi,
  kOri,
  kXori,
  kLui,
  kLb,
  kLbu,
  kLh,
  kLhu,
  kSb,
  kSh,
  kLw,
  kSw,
  kBeq,
  kBne,
  kBgez,
  kBgtz,
  kBlez,
  kBltz,
  kBgezal,
  kBltzal,
  kSlti,
  kSltiu
};

enum class JType : int { kJ, kJal };




class Instr {
  Instr(Kind kind, IType it);
  Instr(Kind kind, RType rt);
  Instr(Kind kind, JType jt);

  bool is_itype() const;
  bool is_rtype() const;
  bool is_jtype() const;
  int get_type() const;

  Instr& set_rs(int32_t rs);
  Instr& set_rt(int32_t rt);
  Instr& set_rd(int32_t rd);
  Instr& set_shamt(int32_t shamt);
  Instr& set_code(int32_t code);
  Instr& set_imm(int32_t imm);
  Instr& set_offset(int32_t offset);
  Instr& set_address(int32_t addr);

private:
  const Kind kind_;
  const std::variant<RType, IType, JType> type_;
  int32_t bc_;
};
