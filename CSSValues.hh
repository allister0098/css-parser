#ifndef CSSVALUES_HH
#define CSSVALUES_HH

#include <string>
#include <array>
#include <sstream>
#include <cstring>

namespace css { 
enum class ValueType : unsigned char {
  Undefined,
  Keyword,
  Length,
  ColorRGBA,
};

enum UNIT { UNIT_PX, UNIT_CM, UNIT_PERCENT };

struct KeywordValue {
  std::string val;
  const ValueType type = ValueType::Keyword;

  inline explicit KeywordValue(const char* text) {
    val = parse(text);
  }

  inline static std::string parse(const char* text) {
    return text;
  }
};

struct LengthValue {
  float val;
  UNIT unit;
  const ValueType type = ValueType::Length;

  inline explicit LengthValue(const char* v, UNIT u = UNIT_PX) : unit(u) {
    val = parse(v);
  }

  inline static float parse(const char* text) {
    return std::stof(text);
  }
};

typedef std::array<unsigned char, 4> RGBA;

struct ColorRGBAValue {
  RGBA rgba;
  const ValueType type = ValueType::ColorRGBA;

  inline explicit ColorRGBAValue(const char* text) {
    rgba = parse(text);
  }

  inline static RGBA parse(const char* text) {
    RGBA rgba;
    unsigned i = 0;

    while (text[i++] != '#');

    rgba[0] = std::stoul(std::string(text, i, i + 2), NULL, 16);
    rgba[1] = std::stoul(std::string(text, i + 2, i + 4), NULL, 16);
    rgba[2] = std::stoul(std::string(text, i + 4, i + 6), NULL, 16);
    rgba[3] = 255;

    return rgba;
  }
};
}; 


#endif
