#pragma once
#include "./instr.hpp"


class Add: public Instr {
public:
  static constexpr uint32_t op = 0b000000;
  static constexpr uint32_t shamt = 0b00000;
  static constexpr uint32_t func = 0b100000;

  uint32_t ToBinary() const final;

  Add();
  uint32_t GetRS() final;
  uint32_t GetRT() final;
  uint32_t GetRD() final;

  Instr& SetRS(uint32_t rs) final;
  Instr& SetRT(uint32_t rt) final;
  Instr& SetRD(uint32_t rd) final;
};

class Addu: public Instr {
public:
  static constexpr uint32_t op = 0b000000;
  static constexpr uint32_t shamt = 0b00000;
  static constexpr uint32_t func = 0b100001;

  uint32_t ToBinary() const final;

  Addu();

  Instr& SetRS(uint32_t rs) final;
  Instr& SetRT(uint32_t rt) final;
  Instr& SetRD(uint32_t rd) final;
};

