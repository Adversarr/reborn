#pragma once
#include <string>
#include <variant>

enum class Kind { kR, kI, kJ };

enum class RType : int {
  kAdd,
  kAddu,
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

public:
  virtual Instr &SetRS(uint32_t rs);
  virtual Instr &SetRT(uint32_t rt);
  virtual Instr &SetRD(uint32_t rd);
  virtual Instr &SetShamt(uint32_t shamt);
  virtual Instr &SetCode(uint32_t code);
  virtual Instr &SetImm(uint32_t imm);
  virtual Instr &SetOffset(uint32_t offset);
  virtual Instr &SetAddress(uint32_t addr);


  virtual uint32_t GetRS();
  virtual uint32_t GetRT();
  virtual uint32_t GetRD();
  virtual uint32_t GetShamt();
  virtual uint32_t GetCode();
  virtual uint32_t GetImm();
  virtual uint32_t GetOffset();
  virtual uint32_t GetAddress();


  /**
   * Any instruction derived from the class should implement this method
   */
  virtual uint32_t ToBinary() const;

  static Instr FromBinary(uint32_t bc);

  const Kind kind_;

  const std::variant<RType, IType, JType> type_;

protected:
  uint32_t rs_;
  uint32_t rt_;
  uint32_t rd_;
  uint32_t shamt_;
  uint32_t code_;
  uint32_t imm_;
  uint32_t offset_;
  uint32_t addr_;
  Instr(IType it);
  Instr(RType rt);
  Instr(JType jt);
};
