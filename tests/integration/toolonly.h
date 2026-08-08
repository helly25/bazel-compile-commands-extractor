#ifndef HELLY25_BCCE_TESTS_INTEGRATION_TOOLONLY_H_
#define HELLY25_BCCE_TESTS_INTEGRATION_TOOLONLY_H_

#include <string>

namespace integration_test {

// Reachable ONLY through the `generator` tool, so it is compiled solely in the
// exec configuration. --bcce-prefer-target-config must keep this: there is no
// target-configuration command that would otherwise describe it, and dropping
// it would remove the file from compile_commands.json entirely.
std::string ToolOnlyBanner();

}  // namespace integration_test

#endif  // HELLY25_BCCE_TESTS_INTEGRATION_TOOLONLY_H_
