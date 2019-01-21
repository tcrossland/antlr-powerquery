# ANTLR Lexer and Parser for Power Query M

This repository contains lexer and parser grammars for the Power Query
formula language (a.k.a. "M" or Excel Get & Transform) used in Power BI
and Excel. Running the ANTLR tool on the grammars (.g4 files) will generate
Java classes which can be used for lexical analysis and parsing.

## Reference

- [Power Query M Reference](https://docs.microsoft.com/en-us/powerquery-m/power-query-m-reference)
- [Power Query M language specification](https://docs.microsoft.com/en-us/powerquery-m/power-query-m-language-specification)
- [Power Query M language specification (PDF)](<https://download.microsoft.com/download/8/1/A/81A62C9B-04D5-4B6D-B162-D28E4D848552/Power%20Query%20Formula%20Language%20Specification%20(October%202016).pdf>)
- [The Definitive ANTLR 4 Reference](https://pragprog.com/book/tpantlr2/the-definitive-antlr-4-reference)

**Note:** The language specification contains some issues (e.g.
[#1058](https://github.com/MicrosoftDocs/feedback/issues/1058)) and also
appears to be incomplete (e.g. it doesn't contain the parser rules for
intrinsic functions such as `#table`.)

## How to...

### Build library

`./gradlew build`

### Parse a file using TestRig (grun)

```shell
source ./anltr.sh
grun io.truedat.PowerQueryFormula section_document data/section_document/1.m -gui
```

### Troubleshoot parsing issues

First of all, isolate the syntax which is causing issues, then use `TestRig` (grun) to attempt parsing
using the rule you want to test, for example...

```shell
source ./anltr.sh
grun io.truedat.PowerQueryFormula let_expression data/let_expression/1.m -tree -tokens -diagnostic -trace
```

The `data` directory contains some examples.
