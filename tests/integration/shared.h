#ifndef HELLY25_BCCE_TESTS_INTEGRATION_SHARED_H_
#define HELLY25_BCCE_TESTS_INTEGRATION_SHARED_H_

#include <string>

namespace integration_test {

// Compiled in BOTH configurations: `greeter_lib` pulls it in normally (target
// configuration) and the `generator` tool pulls it in as a build-machine tool
// (exec configuration). Bazel therefore emits two compile actions for
// shared.cc, which is exactly what --bcce-prefer-target-config deduplicates.
std::string SharedName();

}  // namespace integration_test

#endif  // HELLY25_BCCE_TESTS_INTEGRATION_SHARED_H_
