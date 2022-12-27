#include "asmer.h"
#include <iomanip>
#include <iostream>
#include <fstream>
#include <sstream>


#include "data_seg.hpp"
#include "prog_seg.hpp"
#include "utils.hpp"
#include <spdlog/sinks/stdout_color_sinks.h>
#include <spdlog/spdlog.h>

inline bool start_with(std::string_view s1, std::string_view pat) {
  if (s1.length() < pat.length()) {
    return false;
  } else if (s1.substr(0, pat.length()) == pat) {
    return true;
  } else {
    return false;
  }
}

std::string remove_ws(const std::string &s) {
  int start = mias::find_first_nws(s);
  int end = s.length() - 1;
  while (end > start) {
    if (!std::isspace(s[end])) {
      break;
    }
    end -= 1;
  }
  return s.substr(start, end - start + 1);
}

struct ASMDesc {
  std::vector<std::string> data;
  std::vector<std::string> text;
} desc;

void RunInput(std::istream &input) {
  std::vector<std::string> input_str;
  while (!input.eof()) {
    std::string line;
    std::getline(input, line);
    std::string clear;
    auto beg = mias::find_first_nws(line);
    if (beg != line.length()) {
      // Not Empty.
      line = line.substr(beg);
      bool is_in_string = false;
      for (auto c : line) {
        if (c == '"') {
          is_in_string = !is_in_string;
        }
        if (c == '#') {
          if (!is_in_string) {
            break;
          }
        }
        clear.push_back(c);
      }
      if (is_in_string) {
        spdlog::error("Unterminated String {}", line);
        throw std::runtime_error("Preprocessing Error");
      }
      // remove rebundant spaces:
      int i = clear.length() - 1;
      while (i > 0 && std::isspace(clear[i])) {
        i -= 1;
      }
      clear = clear.substr(0, i + 1);
      if (!clear.empty()) {
        input_str.push_back(clear);
      }
    }
  }
  bool is_data_seg = false;
  bool is_text_seg = false;
  for (auto line : input_str) {
    if (start_with(mias::strtolower(line), ".data")) {
      is_data_seg = true;
      is_text_seg = false;
    } else if (start_with(mias::strtolower(line), ".text")) {
      is_text_seg = true;
      is_data_seg = false;
    } else if (is_data_seg) {
      desc.data.push_back(line);
    } else if (is_text_seg) {
      desc.text.push_back(line);
    } else {
      spdlog::warn("Instr Without Segment Flag: {}, ignored.", line);
    }
  }

  for (int i = 0; i < desc.data.size(); ++i) {
    auto it = desc.data.begin() + i;
    auto comma = it->find(':');
    *it = remove_ws(*it);
    spdlog::debug("Processing '{}', comma={}", *it, comma);
    if (comma != std::string::npos) {
      // on the left, is alpha, digit, space.
      auto l = it->substr(0, comma);
      if (std::all_of(l.begin(), l.end(), [](char c) {
            return std::isalpha(c) || std::isdigit(c) || std::isspace(c) ||
                   c == '_';
          })) {
        // yes
        auto lc = remove_ws(it->substr(0, comma + 1));
        auto rc = remove_ws(it->substr(comma + 1));
        spdlog::debug("Found ':' in '{}', at {}, lc = '{}', rc = '{}'", *it,
                      comma, lc, rc);
        if (!rc.empty()) {
          *it = rc;
          desc.data.insert(it, lc);
        }
      }
    }
  }

  for (int i = 0; i < desc.text.size(); ++i) {
    auto it = desc.text.begin() + i;
    auto comma = it->find(':');
    *it = remove_ws(*it);
    spdlog::debug("Processing '{}'", *it);
    if (comma != std::string::npos) {
      // on the left, is alpha, digit, space.
      auto l = it->substr(0, comma);
      if (std::all_of(l.begin(), l.end(), [](char c) {
            return std::isalpha(c) || std::isdigit(c) || std::isspace(c) ||
                   c == '_';
          })) {
        // yes
        auto lc = remove_ws(it->substr(0, comma + 1));
        auto rc = remove_ws(it->substr(comma + 1));
        spdlog::debug("Found ':' in '{}', at {}, lc = '{}', rc = '{}'", *it,
                      comma, lc, rc);
        if (!rc.empty()) {
          *it = rc;
          desc.text.insert(it, lc);
        }
      }
    }
  }
}

void GenerateCOE(std::string path, const std::vector<uint32_t> &data,
                 uint32_t kbs) {
  auto n = kbs * 256;
  std::ofstream out(path);
  if (!out.is_open()) {
    spdlog::error("Cannot Open File {}", path);
    throw std::runtime_error("Cannot Open File Error");
  }

  out << "memory_initialization_radix = 16;" << std::endl;
  out << "memory_initialization_vector =" << std::endl;
  for (auto value : data) {
    out << std::setw(8) << std::setfill('0') << std::hex << value;
    n -= 1;
    if (n == 0) {
      out << ";" << std::endl;
      break;
    } else {
      out << "," << std::endl;
    }
  }
  while (n > 1) {
    out << "00000000," << std::endl;
    n -= 1;
  }

  if (n > 0) {
    out << "00000000;" << std::endl;
  }
  out.close();
}

void GenerateOutput(std::ostream &os, uint32_t kbs, bool fill_zero,
                    mias::PmemDesc &pseg, mias::DmemDesc &dseg) {
  std::string magic_number = "03020000";
  if (kbs == 4) {
    magic_number = "022000";
  } else if (kbs == 8) {
    magic_number = "024000";
  } else if (kbs == 16) {
    magic_number = "028000";
  } else if (kbs == 32) {
    magic_number = "020000";
  } else if (kbs == 128) {
    magic_number = "03040000";
  }
  os << magic_number;
  for (uint32_t i = 0; i < kbs * 256; ++i) {
    if (i < pseg.binary_instrs.size()) {
      os << std::setw(8) << std::setfill('0') << std::hex << std::noshowbase
         << pseg.binary_instrs[i];
    } else if (fill_zero) {
      os << std::setw(8) << std::setfill('0') << std::hex << std::noshowbase
         << 0;
    } else {
      break;
    }
  }

  for (uint32_t i = 0; i < kbs * 256; ++i) {
    if (i < dseg.dmem_value.size()) {
      os << std::setw(8) << std::setfill('0') << std::hex << std::noshowbase
         << dseg.dmem_value[i];
    } else if (fill_zero) {
      os << std::setw(8) << std::setfill('0') << std::hex << std::noshowbase
         << 0;
    } else {
      break;
    }
  }
}

Asmer::Asmer()
{

}


QString Asmer::Run(QString str) {
  mias::DataSegParser dp;
  dp.Parse(desc.data);
  auto dseg = dp.Describe();
  mias::ProgSegParser pp;
  pp.SetDmemDesc(dseg);
  pp.Parse(desc.text);
  auto pseg = pp.Describe();
  std::ostringstream oss;
  GenerateOutput(oss, kbs, true, pseg, dseg);
  return QString(oss.str().c_str());
}



