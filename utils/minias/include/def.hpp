#pragma once
#include <cstdint>
#include <string>


#define Def(name, value) static constexpr int32_t name = value;\
    static constexpr char s_##name [] = #value;


struct Add{
  Def(op, 000000);
  Def(shamt, 00000);
  Def(func, 100000);
  inline int32_t compose(int32_t rs, int32_t rt, int32_t rd) {
    return op << 26 | rs << 21 | rt << 16 | rd << 11 | shamt << 6 | func;
  }
};

struct Addu{
  Def(op, 000000);
  Def(shamt, 00000);
  Def(func, 100001);
  inline int32_t compose(int32_t rs, int32_t rt, int32_t rd) {
    return op << 26 | rs << 21 | rt << 16 | rd << 11 | shamt << 6 | func;
  }
};


struct Sub{
  Def(op, 000000);
  Def(shamt, 00000);
  Def(func, 100010);
  inline int32_t compose(int32_t rs, int32_t rt, int32_t rd) {
    return op << 26 | rs << 21 | rt << 16 | rd << 11 | shamt << 6 | func;
  }
};

struct Subu{
  Def(op, 000000);
  Def(shamt, 00000);
  Def(func, 100011);
  inline int32_t compose(int32_t rs, int32_t rt, int32_t rd) {
    return op << 26 | rs << 21 | rt << 16 | rd << 11 | shamt << 6 | func;
  }
};

struct And{
  Def(op, 000000);
  Def(shamt, 00000);
  Def(func, 100100);
  inline int32_t compose(int32_t rs, int32_t rt, int32_t rd) {
    return op << 26 | rs << 21 | rt << 16 | rd << 11 | shamt << 6 | func;
  }
};



struct Mult{
  Def(op, 000000);
  Def(func, 011000);
  inline int32_t compose(int32_t rs, int32_t rt) {
    return op << 26 | rs << 21 | rt << 16 | func;
  }
};


struct Multu{
  Def(op, 000000);
  Def(func, 011001);
  inline int32_t compose(int32_t rs, int32_t rt) {
    return op << 26 | rs << 21 | rt << 16 | func;
  }
};


struct Div{
  Def(op, 000000);
  Def(func, 011010);
  inline int32_t compose(int32_t rs, int32_t rt) {
    return op << 26 | rs << 21 | rt << 16 | func;
  }
};


struct Divu{
  Def(op, 000000);
  Def(func, 011011);
  inline int32_t compose(int32_t rs, int32_t rt) {
    return op << 26 | rs << 21 | rt << 16 | func;
  }
};


struct Mfhi{
  Def(op, 000000);
  Def(func, 010000);
  inline int32_t compose(int32_t rd) {
    return op << 26 | rd << 11 | func;
  }
};

struct Mflo{
  Def(op, 000000);
  Def(func, 010010);
  inline int32_t compose(int32_t rd) {
    return op << 26 | rd << 11 | func;
  }
};

struct Mthi {
  Def(op, 000000);
  Def(func, 010001);
  inline int32_t compose(int32_t rs) {
    return op << 26 | rs << 21 | func;
  }
};

struct Mtlo {
  Def(op, 000000);
  Def(func, 010001);

  inline int32_t compose(int32_t rs) {
    return op << 26 | rs << 21 | func;
  }
};





