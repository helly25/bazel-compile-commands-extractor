// A trivial code generator, built for the exec configuration because a genrule
// uses it via `tools`. It depends on shared_lib (also used in the target
// configuration) and toolonly_lib (used nowhere else).
#include <iostream>

#include "shared.h"
#include "toolonly.h"

int main() {
  std::cout << integration_test::ToolOnlyBanner() << '\n'
            << "#pragma once\n"
            << "inline const char* GeneratedName() { return \"" << integration_test::SharedName() << "\"; }\n";
  return 0;
}
