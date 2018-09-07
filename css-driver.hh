#ifndef CSS_DRIVER_HH
#define CSS_DRIVER_HH
#include <string>
#include <map>
#include "CSS.hh"
#include "css-parser.hh"

#define YY_DECL \
  css::css_parser::symbol_type csslex (css_driver& driver)
YY_DECL;

class css_driver
{
public:
  css_driver ();
  virtual ~css_driver ();

  std::map<std::string, int> variables;

  css::Stylesheet stylesheet;
  int result;

  // Handling the scanner.
  void scan_begin ();
  void scan_end ();
  bool trace_scanning;

  // Run the parser on file F.
  // Return 0 on success.
  int parse (const std::string& f);
  std::string file;
  bool trace_parsing;

  // Error handling.
  void error (const css::location& l, const std::string& m);
  void error (const std::string& m);

};
#endif

