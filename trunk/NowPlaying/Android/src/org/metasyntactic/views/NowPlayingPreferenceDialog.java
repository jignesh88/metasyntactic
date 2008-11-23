// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
package org.metasyntactic.views;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.graphics.drawable.Drawable;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.AdapterView.OnItemSelectedListener;

import org.metasyntactic.INowPlaying;
import org.metasyntactic.NowPlayingControllerWrapper;
import org.metasyntactic.R;
import org.metasyntactic.caches.scores.ScoreType;

import java.util.Arrays;
import java.util.List;

public class NowPlayingPreferenceDialog {
  private final AlertDialog.Builder builder;
  private PreferenceKeys prefKey;
  private int intValue;
  private String stringValue;
  private TextView mTextView;
  private INowPlaying nowPlaying;
  DialogInterface.OnClickListener positiveButtonListener;

  public NowPlayingPreferenceDialog(final INowPlaying nowPlaying) {
    final Context context = nowPlaying.getContext();
    this.builder = new AlertDialog.Builder(context);
    this.nowPlaying = nowPlaying;
  }

  public NowPlayingPreferenceDialog create() {
    this.builder.create();
    return this;
  }

  public NowPlayingPreferenceDialog setIcon(final Drawable icon) {
    this.builder.setIcon(icon);
    return this;
  }

  public NowPlayingPreferenceDialog setInverseBackgroundForced(
      final boolean useInverseBackground) {
    this.builder.setInverseBackgroundForced(useInverseBackground);
    return this;
  }

  public NowPlayingPreferenceDialog setNegativeButton(final int textId,
      final OnClickListener listener) {
    this.builder.setNegativeButton(textId, listener);
    return this;
  }

  public NowPlayingPreferenceDialog setOnItemSelectedListener(
      final OnItemSelectedListener listener) {
    this.builder.setOnItemSelectedListener(listener);
    return this;
  }

  public NowPlayingPreferenceDialog setEntries(final int items) {
    final DialogInterface.OnClickListener radioButtonListener = new DialogInterface.OnClickListener() {
      public void onClick(final DialogInterface dialog, final int which) {
        intValue = which;
      }
    };
    setSingleChoiceItems(items, getIntPreferenceValue(), radioButtonListener);
    positiveButtonListener = new DialogInterface.OnClickListener() {
      public void onClick(final DialogInterface dialog, final int which) {
        setIntPreferenceValue(intValue);
        nowPlaying.refresh();
      }
    };
    return this;
  }

  private NowPlayingPreferenceDialog setSingleChoiceItems(final int items,
      final int checkedItem, final OnClickListener listener) {
    this.builder.setSingleChoiceItems(items, checkedItem, listener);
    return this;
  }

  public NowPlayingPreferenceDialog setItems(final String[] distanceValues) {
    final DialogInterface.OnClickListener listItemListener = new DialogInterface.OnClickListener() {
      public void onClick(DialogInterface dialog, int which) {
        setIntPreferenceValue(Integer.parseInt(distanceValues[which]));
        nowPlaying.refresh();
      }
    };
    this.builder.setItems(distanceValues, listItemListener);
    return this;
  }

  public NowPlayingPreferenceDialog setTitle(final int title) {
    this.builder.setTitle(title);
    return this;
  }

  public NowPlayingPreferenceDialog setTitle(final CharSequence title) {
    this.builder.setTitle(title);
    return this;
  }

  public NowPlayingPreferenceDialog setPositiveButton(int textId) {
    this.builder.setPositiveButton(textId, positiveButtonListener);
    return this;
  }

  public NowPlayingPreferenceDialog setNegativeButton(int textId) {
    this.builder.setNegativeButton(textId, null);
    return this;
  }

  public NowPlayingPreferenceDialog setKey(final PreferenceKeys key) {
    this.prefKey = key;
    return this;
  }

  public void show() {
    this.builder.show();
  }

  private int getIntPreferenceValue() {
    switch (this.prefKey) {
    case MOVIES_SORT:
      return NowPlayingControllerWrapper.getAllMoviesSelectedSortIndex();
    case THEATERS_SORT:
      return NowPlayingControllerWrapper.getAllTheatersSelectedSortIndex();
    case SEARCH_DISTANCE:
      return NowPlayingControllerWrapper.getSearchDistance();
    case REVIEWS_PROVIDER:
      return scoreTypes.indexOf(NowPlayingControllerWrapper.getScoreType());
    case AUTO_UPDATE_LOCATION:
      return autoUpdate.indexOf(NowPlayingControllerWrapper
          .isAutoUpdateEnabled());
    }
    return 0;
  }

  private String getStringPreferenceValue() {
    switch (this.prefKey) {
    case LOCATION:
      return NowPlayingControllerWrapper.getUserLocation();
    }
    return null;
  }

  private void setIntPreferenceValue(int prefValue) {
    switch (this.prefKey) {
    case MOVIES_SORT:
      NowPlayingControllerWrapper.setAllMoviesSelectedSortIndex(prefValue);
      break;
    case THEATERS_SORT:
      NowPlayingControllerWrapper.setAllTheatersSelectedSortIndex(prefValue);
      break;
    case SEARCH_DISTANCE:
      NowPlayingControllerWrapper.setSearchDistance(prefValue);
      break;
    case REVIEWS_PROVIDER:
      NowPlayingControllerWrapper.setScoreType(scoreTypes.get(prefValue));
      break;
    case AUTO_UPDATE_LOCATION:
      NowPlayingControllerWrapper.setAutoUpdateEnabled(autoUpdate
          .get(prefValue));
      break;
    }
  }

  private void setStringPreferenceValue(String prefValue) {
    switch (this.prefKey) {
    case LOCATION:
      NowPlayingControllerWrapper.setUserLocation(prefValue);
      break;
    }
  }

  public enum PreferenceKeys {
    MOVIES_SORT, THEATERS_SORT, LOCATION, SEARCH_DISTANCE, SEARCH_DATE, REVIEWS_PROVIDER, AUTO_UPDATE_LOCATION
  }

  public NowPlayingPreferenceDialog setTextView(View textEntryView) {
    mTextView = (TextView) textEntryView.findViewById(R.id.dialogEdit);
    mTextView.setText(getStringPreferenceValue());
    this.builder.setView(textEntryView);
    positiveButtonListener = new DialogInterface.OnClickListener() {
      public void onClick(final DialogInterface dialog, final int which) {
        setStringPreferenceValue(mTextView.getText().toString());
        nowPlaying.refresh();
      }
    };
    return this;
  }

  // Work around to make handling of scoretype,auto_update same as sort
  // preference, as both are choicetypes.
  private final List<ScoreType> scoreTypes = Arrays.asList(ScoreType.Google,
      ScoreType.Metacritic, ScoreType.RottenTomatoes);
  private final List<Boolean> autoUpdate = Arrays.asList(Boolean.TRUE,
      Boolean.FALSE);
}
