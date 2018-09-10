#ifndef CSSBASEVALUE_HH
#define CSSBASEVALUE_HH

#include "CSSValues.hh"
#include <iostream>
#include <stdexcept>

namespace css {
class CSSBaseValue
{
private:
  struct m_base {
    virtual ~m_base() {}
    virtual m_base* clone() const = 0;
  };

  template <typename T>
  struct m_data : m_base {
    T _value;

    m_data(T const& value) : _value(value) {}

    m_base* clone() const { return new m_data<T>(*this); }
  };

  m_base* _ptr;

public:
  ValueType type;

public:
  CSSBaseValue() {
    type = ValueType::Undefined;
    _ptr = new m_data<char>(0);
  }

  template <typename T>
  CSSBaseValue(T const& value) : _ptr(new m_data<T>(value)) {
    type = value.type;
  }

  ~CSSBaseValue() {
    if (this->_ptr)
      delete this->_ptr;
    this->_ptr = nullptr;
  }

  template <typename T>
  inline const T& get() {
    return static_cast<m_data<T>&>(*this->_ptr)._value;
  }

};
};


#endif
