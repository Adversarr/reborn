#include "r_instr.hpp"


/* ADD */

uint32_t Add::ToBinary() const {
  return op << 26 | rs_ << 21 | rt_ << 16 | rd_ << 11 | shamt << 6 | func;
}

Instr& Add::SetRS(uint32_t rs) {
  rs_ = rs;
  return *this;
}

Instr& Add::SetRT(uint32_t rt) {
  rt_ = rt;
  return *this;
}

Instr& Add::SetRD(uint32_t rd) {
  rd_ = rd;
  return *this;
}

Add::Add(): Instr(RType::kAdd) {}

uint32_t Add::GetRS() {
  return rs_;
}

uint32_t Add::GetRT() {
  return rt_;
}

uint32_t Add::GetRD() {
  return rd_;
}



