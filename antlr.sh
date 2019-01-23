#!/bin/bash
export CLASSPATH=".:$CLASSPATH"

alias antlr4='java -Xmx500M -cp "./lib/antlr-4.7.2-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
alias grun='java -Xmx500M -cp "./build/libs/antlr-1.0-SNAPSHOT.jar:./lib/antlr-4.7.2-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig'
