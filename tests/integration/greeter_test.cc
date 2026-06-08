#include <cstdio>
#include <string>

#include "greeter.h"

// Minimal, framework-free cc_test: returns non-zero on failure. We avoid
// `assert` because it is compiled out under NDEBUG (opt builds).
int main() {
  const std::string expected = "Hello from the integration test binary!";
  const std::string actual = integration_test::Greeting();
  if (actual != expected) {
    std::fprintf(stderr, "FAIL: Greeting() = \"%s\", expected \"%s\"\n",
                 actual.c_str(), expected.c_str());
    return 1;
  }
  std::puts("PASS: Greeting() returns the expected string");
  return 0;
}
