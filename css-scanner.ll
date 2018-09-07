%{
  #include <cerrno>
  #include <climits>
  #include <cstdlib>
  #include <string>
  #include "css-driver.hh"
  #include "css-parser.hh"
  
  //#undef yywrap
  //#define yywrap() 1
  
  // The location of the current token.
  static css::location loc;
  static std::string comment;
%}

%option noyywrap nounput batch debug noinput
%option prefix="css"
%pointer

%x DECL

OWS [ \r\t\n\f]*
COMMA               {OWS}","{OWS}
SC                  {OWS}";"{OWS}
LCB                 "{"{OWS}
RCB                 {OWS}"}"{OWS}

HEX                 [0-9a-fA-F]
DIGIT               [0-9]
NMSTART             [_a-zA-Z]
NMCHAR              [_a-zA-Z0-9-]
FLOAT               ({DIGIT}*".")?{DIGIT}+

IDENT               -?{NMSTART}{NMCHAR}*

DECL_KEY            {IDENT}":"

DECL_PX             " "+{FLOAT}"px"?{OWS}
DECL_HEXC           " "+"#"{HEX}{6}{OWS}
DECL_STR            " "+[^:\r\n;}{]+

STAR                "*"
ELEM                {IDENT}
ID                  "#"{IDENT}
CLASS               "."{IDENT}

COMMENTS            {OWS}\/\*[^*]*\*+([^/*][^*]*\*+)*\/{OWS}

%{
  // Code run each time a pattern is matched.
  #define YY_USER_ACTION  loc.columns (cssleng);
%}

%%

%{
  // Code run each time yylex is called.
  loc.step ();
%}

{COMMENTS}        {}
<DECL>{COMMENTS}  {}

{ELEM}          return css::css_parser::make_ELEM(csstext, loc);

{STAR}          return css::css_parser::make_STAR(loc);

{ID}            return css::css_parser::make_ID(csstext+1, loc);

{CLASS}         return css::css_parser::make_CLASS(csstext+1, loc);


{COMMA}         return css::css_parser::make_COMMA(loc);

{OWS}           return css::css_parser::make_OWS(loc);

{LCB}           {
                  BEGIN(DECL);
                  return css::css_parser::make_LCB(loc);
                }


<DECL>{RCB}     {
                  BEGIN(INITIAL);
                  return css::css_parser::make_RCB(loc);
                }

<DECL>{SC}        { return css::css_parser::make_SC(loc); }

<DECL>{DECL_KEY}  {
                    return css::css_parser::make_DECL_KEY(
                    std::string(csstext, 0, cssleng-1), loc);
                  }

<DECL>{DECL_PX}   {
                    return css::css_parser::make_DECL_VAL(
                    css::LengthValue(csstext), loc);
                  }

<DECL>{DECL_HEXC} {
                    return css::css_parser::make_DECL_VAL(
                    css::ColorRGBAValue(csstext), loc);
                  }

<DECL>{DECL_STR} {
                    return css::css_parser::make_DECL_VAL(
                    css::KeywordValue(csstext), loc);
                 }
<<EOF>>         return css::css_parser::make_END(loc);

%%


void
css_driver::scan_begin ()
{
  css_flex_debug = trace_scanning;
  if (file.empty () || file == "-")
    cssin = stdin;
  else if (!(cssin = fopen (file.c_str (), "r")))
    {
      error ("cannot open " + file + ": " + strerror(errno));
      exit (EXIT_FAILURE);
    }
}

void
css_driver::scan_end ()
{
  fclose (cssin);
}

