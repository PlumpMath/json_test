#include "json.hpp"
#include <iostream>
#include <optional>
#include <string>

namespace nlohmann {

template <typename T>
inline void to_json(json& json, const std::optional<T>& value) {
  if (value) {
    json = value.value();
  } else {
    json = nullptr;
  }
}

template <typename T>
inline void from_json(const json& json, std::optional<T>& value) {
  if (json.is_null()) {
    value = {};
  } else {
    value = json.get<T>();
  }
}

}  // namespace nlohmann

int main() {
  nlohmann::json json(std::optional<std::string>("test"));
  std::cout << json.get<std::optional<std::string>>().value() << std::endl;
}
