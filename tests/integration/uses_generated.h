#ifndef HELLY25_BCCE_TESTS_INTEGRATION_USES_GENERATED_H_
#define HELLY25_BCCE_TESTS_INTEGRATION_USES_GENERATED_H_

#include <string>

namespace integration_test {

// Consumes the genrule output, which is what drags the `generator` tool (and
// therefore the exec-configuration compile actions) into the build graph.
std::string GeneratedGreeting();

}  // namespace integration_test

#endif  // HELLY25_BCCE_TESTS_INTEGRATION_USES_GENERATED_H_
