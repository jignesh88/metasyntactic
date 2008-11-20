package com.google.automata.compiler.python.scanner.delimiters;

import com.google.automata.compiler.python.scanner.PythonToken;

public class LeftBracketDelimiterToken extends DelimiterToken {
  public static final LeftBracketDelimiterToken instance = new LeftBracketDelimiterToken();

  private LeftBracketDelimiterToken() {
    super("[");
  }
}
