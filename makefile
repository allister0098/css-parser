# Makefile


all: css.out

css.out: css-driver.o css-parser.o css-scanner.o css.o 
	g++ --std=c++11 -o css.out css-driver.o css-parser.o css-scanner.o css.o 

css-driver.o: css-driver.cc css-driver.hh css-parser.hh 
	g++ --std=c++11 -c css-driver.cc

css-parser.o: css-parser.cc css-parser.hh css-driver.hh
	g++ --std=c++11 -c css-parser.cc

css-parser.cc css-parser.hh: css-parser.yy
	bison --defines=css-parser.hh -o css-parser.cc css-parser.yy

css-scanner.o: css-scanner.cc css-parser.hh css-driver.hh
	g++ --std=c++11 -c css-scanner.cc

css-scanner.cc: css-scanner.ll
	flex -o css-scanner.cc css-scanner.ll

css.o: css.cc
	g++ --std=c++11 -c css.cc

.PHONY: clean

clean:
	rm *.o css-parser.hh css-parser.cc css-scanner.cc location.hh position.hh stack.hh css.out lex.css.cc
