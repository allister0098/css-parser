#include "css-driver.hh"
#include "css-parser.hh"

css_driver::css_driver ()
  : trace_scanning (false), trace_parsing (false)
{
  variables["one"] = 1;
  variables["two"] = 2;
}

css_driver::~css_driver ()
{
}

int
css_driver::parse (const std::string &f)
{
  std::cout << "got a css file" << std::endl;
  file = f;
  scan_begin ();
  css::css_parser parser (*this);
  parser.set_debug_level (trace_parsing);
  int res = parser.parse ();
  scan_end ();
  std::cout << stylesheet.rules[0]->selectors[0].id << std::endl;
  std::cout << stylesheet.rules[0]->selectors[1].tag << std::endl;
  return res;

}

void
css_driver::error (const css::location& l, const std::string& m)
{
  std::cerr << l << ": " << m << '\n';
}

void
css_driver::error (const std::string& m)
{
  std::cerr << m << '\n';
}

