%skeleton "lalr1.cc"
%require "3.0.4"
%defines

%define api.prefix {css}
%define api.namespace {css}
%define parser_class_name {css_parser}
%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires
{
  #include <string>
  #include "CSS.hh"
  class css_driver;
}

// The parsing context.
%param { css_driver& driver }

%locations
%initial-action
{
  // Initialize the initial location.
  @$.begin.filename = @$.end.filename = &driver.file;
};

%define parse.trace
%define parse.error verbose

%code
{
  #include "css-driver.hh"
}

%define api.token.prefix {TOK_}
%token
  END  0  "end of file"
  OWS     " "
  LCB     "{"
  RCB     "}"
  COMMA   ","
  STAR    "*"
  SC      ";"
;

%token <std::string>
  ELEM
  CLASS
  ID
  DECL_KEY
;

%token <CSSBaseValue> DECL_VAL;

%type <Stylesheet> stylesheet;
%type <RulePtr> rule;
%type <RulePtrContainer> rules;
%type <Declaration> declaration;
%type <DeclarationContainer> declarations;
%type <Selector> selector;
%type <SelectorContainer> selectors;


%%
%start stylesheet;

stylesheet
  : rules {
  driver.stylesheet = Stylesheet { $1 };
  $$ = driver.stylesheet;
          }
  ;


rules
  : %empty         { $$ = RulePtrContainer {}; }
  | rule           { $$ = RulePtrContainer { $1 }; }
  | rules rule     { $1.push_back($2); $$ = $1; }
  ;

rule
  : selectors OWS LCB declarations RCB {
  //std::sort($1.begin(), $1.end(), std::greater<Selector>());
  $$ = std::make_shared<Rule>($1, $4);
                                       }
  ;


selectors
  : selector                 { $$ = SelectorContainer { $1 }; }
  | selectors COMMA selector { $1.push_back($3); $$ = $1; }
  ;

selector
  : ELEM            {
  Selector sel;
  sel.tag = $1;
  sel.specificity += 1;
  $$ = sel;
                    }
  | ID              {
  Selector sel;
  sel.id = $1;
  sel.specificity += 100;
  $$ = sel;
                    }
  | CLASS           {
  Selector sel;
  sel.classes = std::vector<std::string> { $1 };
  sel.specificity += 10;
  $$ = sel;
                    }
  | STAR            {
  Selector sel;
  sel.tag = "*";
  $$ = sel;
                    }
  | selector ELEM   {
  $1.tag = $2;
  $1.specificity += 1;
  $$ = $1;
  }
  | selector STAR   {
  $1.tag = "*"; 
  $$ = $1;
  }
  | selector ID     {
  $1.id = $2;
  $$.specificity += 100;
  $$ = $1;
  }
  | selector CLASS  {
  $1.classes.push_back($2);
  $1.specificity += 10;
  $$ = $1;
                    }
  ;


declarations
  : %empty                        { $$ = DeclarationContainer {}; }
  | declaration                   { $$ = DeclarationContainer { $1 }; }
  | declarations declaration      { $1.emplace($2); $$ = $1; }
  ;

declaration
  : DECL_KEY DECL_VAL { $$ = Declaration {$1, $2}; }
  | DECL_KEY DECL_VAL SC { $$ = Declaration {$1, $2}; }
  ;

%%

void
css::css_parser::error (const location_type& l,
                            const std::string& m)
{
	driver.error (l, m);
}

