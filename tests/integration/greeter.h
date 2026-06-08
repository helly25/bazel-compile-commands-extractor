#ifndef HELLY25_BCCE_TESTS_INTEGRATION_GREETER_H_
#define HELLY25_BCCE_TESTS_INTEGRATION_GREETER_H_

#include <string>

namespace integration_test {

// Returns the greeting printed by the test binary and checked by both the
// cc_test (greeter_test) and the bash output test (binary_output_test).
std::string Greeting();

}  // namespace integration_test

#endif  // HELLY25_BCCE_TESTS_INTEGRATION_GREETER_H_
