#include "uses_generated.h"

#include <string>

#include "generated.h"
#include "shared.h"

namespace integration_test {

std::string GeneratedGreeting() { return std::string(GeneratedName()) + "/" + SharedName(); }

}  // namespace integration_test
