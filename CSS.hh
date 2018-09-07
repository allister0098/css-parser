#ifndef CSS_HH
#define CSS_HH

#include "CSSBaseValue.hh"
#include "CSSValues.hh"

#include <vector>
#include <map>
#include <memory>
#include <string>
#include <utility>
#include <iostream>

namespace css {

struct Stylesheet;
struct Rule;
struct Selector;

typedef std::pair<std::string, CSSBaseValue> Declaration;
typedef std::map<std::string, CSSBaseValue> DeclarationContainer;

typedef std::shared_ptr<Rule> RulePtr;
typedef std::vector<RulePtr> RulePtrContainer;

typedef std::vector<Selector> SelectorContainer;

struct Selector
{
  std::string tag;
  std::string id;
  std::vector<std::string> classes;
  unsigned specificity = 0;
};

struct Stylesheet
{
  RulePtrContainer rules;
};

struct Rule
{
  SelectorContainer selectors;
  DeclarationContainer declarations;

  inline explicit Rule (SelectorContainer sel, DeclarationContainer decl)
    : selectors(sel), declarations(decl)
  {}
};

};

#endif
