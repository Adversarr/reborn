#include "instr.hpp"
#include <stdexcept>

Instr &Instr::SetRS(uint32_t rs) {
  throw std::runtime_error("cannot set rs on this object.");
}

Instr &Instr::SetRT(uint32_t rt) {
  throw std::runtime_error("cannot set rt on this object.");
}

Instr &Instr::SetRD(uint32_t) {
  throw std::runtime_error("cannot set rd on this object.");
}

Instr &Instr::SetShamt(uint32_t) {
  throw std::runtime_error("cannot set shamt on this object.");
}

Instr &Instr::SetCode(uint32_t) {
  throw std::runtime_error("cannot set code on this object.");
}

Instr &Instr::SetImm(uint32_t) {
  throw std::runtime_error("cannot set immediate on this object.");
}

Instr &Instr::SetOffset(uint32_t) {
  throw std::runtime_error("cannot set offest on this object.");
}

Instr &Instr::SetAddress(uint32_t) {
  throw std::runtime_error("cannot set address on this object.");
}

Instr::Instr(RType t) : kind_(Kind::kR), type_(t) {}

Instr::Instr(JType t) : kind_(Kind::kJ), type_(t) {}

Instr::Instr(IType t) : kind_(Kind::kI), type_(t) {}

uint32_t Instr::ToBinary() const {
  throw std::runtime_error("Not implemented");
}


uint32_t Instr::GetRS() {
  throw std::runtime_error("cannot get rs on this object.");
}

uint32_t Instr::GetRT() {
  throw std::runtime_error("cannot get rt on this object.");
}

uint32_t Instr::GetRD() {
  throw std::runtime_error("cannot get rd on this object.");
}

uint32_t Instr::GetShamt() {
  throw std::runtime_error("cannot get shamt on this object.");
}

uint32_t Instr::GetCode() {
  throw std::runtime_error("cannot get code on this object.");
}

uint32_t Instr::GetImm() {
  throw std::runtime_error("cannot get immediate on this object.");
}

uint32_t Instr::GetOffset() {
  throw std::runtime_error("cannot get offest on this object.");
}

uint32_t Instr::GetAddress() {
  throw std::runtime_error("cannot get address on this object.");
}
