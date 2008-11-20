// Copyright 2008 Google Inc. All rights reserved.

package com.google.automata.compiler.java.scanner.keywords;

public class TryKeywordToken extends KeywordToken {
  public static final TryKeywordToken instance = new TryKeywordToken();

  private TryKeywordToken() {
    super("try");
  }
}
