# compat
C++17 compatibility library for Visual Studio 2015, Visual Studio 2015 Clang/C2 and Clang 4.0.

```cpp
#include <filesystem>
#include <iostream>
#include <optional>
#include <variant>
#include <string_view>

using value = std::variant<int, std::string_view>;

void print(const value& v)
{
  switch (auto index = v.index()) {
  case 0: std::cout << "i: " << std::get<0>(v); break;
  case 1: std::cout << "s: " << std::get<std::string_view>(v); break;
  }
  std::cout << std::endl;
}

std::optional<std::filesystem::path> current_path()
{
  const auto path = std::filesystem::current_path();
  if (!std::filesystem::is_empty(path)) {
    return std::filesystem::canonical(path);
  }
  return {};
}

int main()
{
  print(1);
  if (auto path = current_path()) {
    print(std::string_view(path.value().u8string()));
  }
}
```
