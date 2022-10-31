#include "r_instr.hpp"
#include"simu.hpp"
#include <co/flag.h>
#include <iostream>
#include <iomanip>

struct Ref{
  int & data;
  Ref(int& d): data(d) {}
  Ref(const Ref &) = delete;
  Ref(Ref&& ) = default;
};

Ref get_ref() {
  int p = 123;
  std::cout << &p << std::endl;
  return Ref(p);
}


int main(int argc, char** argv) {
  flag::init(argc, argv);
  auto r = get_ref();
  std::cout << &(r.data) << std::endl;

  return 0;
}
