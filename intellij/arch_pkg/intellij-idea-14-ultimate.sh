#!/bin/sh
[[ "$IDEA_JDK" == "" ]] && IDEA_JDK=$JAVA_HOME
export IDEA_JDK

exec /usr/share/intellij-idea-14-ultimate/bin/idea.sh "$@"
