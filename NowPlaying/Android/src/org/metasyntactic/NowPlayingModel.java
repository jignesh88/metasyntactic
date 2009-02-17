//Copyright 2008 Cyrus Najmabadi
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.
package org.metasyntactic;

import android.content.Context;
import android.content.SharedPreferences;
import org.metasyntactic.caches.IMDbCache;
import org.metasyntactic.caches.TrailerCache;
import org.metasyntactic.caches.UpcomingCache;
import org.metasyntactic.caches.UserLocationCache;
import org.metasyntactic.caches.posters.LargePosterCache;
import org.metasyntactic.caches.posters.PosterCache;
import org.metasyntactic.caches.scores.ScoreCache;
import org.metasyntactic.caches.scores.ScoreType;
import org.metasyntactic.data.*;
import org.metasyntactic.providers.DataProvider;
import static org.metasyntactic.utilities.CollectionUtilities.size;
import org.metasyntactic.utilities.DateUtilities;
import static org.metasyntactic.utilities.StringUtilities.isNullOrEmpty;

import java.io.File;
import java.util.*;

public class NowPlayingModel {
  private final static String VERSION = "14";
  private final static String VERSION_KEY = "VERSION";
  private final static String USER_ADDRESS_KEY = "userAddress";
  private final static String SEARCH_DATE_KEY = "searchDate";
  private final static String SEARCH_DISTANCE_KEY = "searchDistance";
  private final static String SELECTED_TAB_INDEX_KEY = "selectedTabIndex";
  private final static String ALL_MOVIES_SELECTED_SORT_INDEX_KEY = "allMoviesSelectedSortIndex";
  private final static String ALL_THEATERS_SELECTED_SORT_INDEX_KEY = "allTheatersSelectedSortIndex";
  private final static String UPCOMING_MOVIES_SELECTED_SORT_INDEX_KEY = "upcomingMoviesSelectedSortIndex";
  private final static String SCORE_TYPE_KEY = "scoreType";
  private final static String AUTO_UPDATED_ENABLED_KEY = "autoUpdateEnabled";
  private final static String CLEAR_CACHE_KEY = "clearCache";
  // SharedPreferences is not threadsafe. so we need to lock when using it
  private final Object preferencesLock = new Object();
  private final SharedPreferences preferences;
  private final DataProvider dataProvider = new DataProvider(this);
  private final ScoreCache scoreCache = new ScoreCache(this);
  private final UserLocationCache userLocationCache = new UserLocationCache();
  private final TrailerCache trailerCache = new TrailerCache(this);
  private final UpcomingCache upcomingCache = new UpcomingCache(this);
  private final PosterCache posterCache = new PosterCache(this);
  private final LargePosterCache largePosterCache = new LargePosterCache(this);
  private final IMDbCache imdbCache = new IMDbCache(this);

  public NowPlayingModel(final Context applicationContext) {
    this.preferences = applicationContext.getSharedPreferences(NowPlayingModel.class.getName(), 0);
    loadData();
    clearCaches();
  }

  private void clearCaches() {
    final int version;
    synchronized (this.preferencesLock) {
      version = this.preferences.getInt(CLEAR_CACHE_KEY, 1);
      this.preferences.edit().putInt(CLEAR_CACHE_KEY, version + 1).commit();
    }

    if (version % 20 == 0) {
      this.largePosterCache.clearStaleData();
      this.upcomingCache.clearStaleData();
      this.trailerCache.clearStaleData();
      this.posterCache.clearStaleData();
      this.scoreCache.clearStaleData();
      this.imdbCache.clearStaleData();
    }
  }

  private void loadData() {
    final String lastVersion = this.preferences.getString(VERSION_KEY, "");
    if (!lastVersion.equals(VERSION)) {
      final SharedPreferences.Editor editor = this.preferences.edit();
      editor.clear();
      editor.putString(VERSION_KEY, VERSION);
      editor.commit();
      Application.reset();
      this.scoreCache.createDirectories();
    }
  }

  public void startup() {
    //update();
  }

  public void shutdown() {
    this.dataProvider.shutdown();
    this.largePosterCache.shutdown();
    this.upcomingCache.shutdown();
    this.trailerCache.shutdown();
    this.posterCache.shutdown();
    this.scoreCache.shutdown();
    this.imdbCache.shutdown();
  }

  public void update() {
    updatePrimaryCaches();
  }

  private void updatePrimaryCaches() {
    this.dataProvider.update();
  }

  public void updateSecondaryCaches() {
    this.scoreCache.update();
    this.trailerCache.update(getMovies());
    this.posterCache.update(getMovies());
    this.upcomingCache.update();
    this.imdbCache.update(getMovies());
  }

  public UserLocationCache getUserLocationCache() {
    return this.userLocationCache;
  }

  public String getUserAddress() {
    synchronized (this.preferencesLock) {
      return this.preferences.getString(USER_ADDRESS_KEY, "");
    }
  }

  public void setUserAddress(final String userLocation) {
    synchronized (this.preferencesLock) {
      final SharedPreferences.Editor editor = this.preferences.edit();
      editor.putString(USER_ADDRESS_KEY, userLocation);
      editor.commit();
    }
    markDataProviderOutOfDate();
  }

  public int getSearchDistance() {
    synchronized (this.preferencesLock) {
      return this.preferences.getInt(SEARCH_DISTANCE_KEY, 5);
    }
  }

  public void setSearchDistance(int searchDistance) {
    synchronized (this.preferencesLock) {
      searchDistance = Math.min(Math.max(searchDistance, 1), 50);
      final SharedPreferences.Editor editor = this.preferences.edit();
      editor.putInt(SEARCH_DISTANCE_KEY, searchDistance);
      editor.commit();
    }
  }

  public Date getSearchDate() {
    synchronized (this.preferencesLock) {
      final long value = this.preferences.getLong(SEARCH_DATE_KEY, 0);
      if (0 == value) {
        return DateUtilities.getToday();
      }
      Date result = new Date(value);
      if (result.before(new Date())) {
        result = DateUtilities.getToday();
        setSearchDate(result);
      }
      return result;
    }
  }

  public void setSearchDate(final Date searchDate) {
    synchronized (this.preferencesLock) {
      final SharedPreferences.Editor editor = this.preferences.edit();
      editor.putLong(SEARCH_DATE_KEY, searchDate.getTime());
      editor.commit();
    }
    markDataProviderOutOfDate();
  }

  private static void markDataProviderOutOfDate() {
    DataProvider.markOutOfDate();
  }

  public int getSelectedTabIndex() {
    synchronized (this.preferencesLock) {
      return this.preferences.getInt(SELECTED_TAB_INDEX_KEY, 0);
    }
  }

  public void setSelectedTabIndex(final int index) {
    synchronized (this.preferencesLock) {
      final SharedPreferences.Editor editor = this.preferences.edit();
      editor.putInt(SELECTED_TAB_INDEX_KEY, index);
      editor.commit();
    }
    Application.refresh();
  }

  public int getAllMoviesSelecetedSortIndex() {
    synchronized (this.preferencesLock) {
      return this.preferences.getInt(ALL_MOVIES_SELECTED_SORT_INDEX_KEY, 0);
    }
  }

  public void setAllMoviesSelectedSortIndex(final int index) {
    synchronized (this.preferencesLock) {
      final SharedPreferences.Editor editor = this.preferences.edit();
      editor.putInt(ALL_MOVIES_SELECTED_SORT_INDEX_KEY, index);
      editor.commit();
    }
    Application.refresh();
  }

  public int getAllTheatersSelectedSortIndex() {
    synchronized (this.preferencesLock) {
      return this.preferences.getInt(ALL_THEATERS_SELECTED_SORT_INDEX_KEY, 1);
    }
  }

  public void setAllTheatersSelectedSortIndex(final int index) {
    synchronized (this.preferencesLock) {
      final SharedPreferences.Editor editor = this.preferences.edit();
      editor.putInt(ALL_THEATERS_SELECTED_SORT_INDEX_KEY, index);
      editor.commit();
    }
    Application.refresh();
  }

  public int getUpcomingMoviesSelectedSortIndex() {
    synchronized (this.preferencesLock) {
      return this.preferences.getInt(UPCOMING_MOVIES_SELECTED_SORT_INDEX_KEY, 0);
    }
  }

  public void setUpcomingMoviesSelectedSortIndex(final int index) {
    synchronized (this.preferencesLock) {
      final SharedPreferences.Editor editor = this.preferences.edit();
      editor.putInt(UPCOMING_MOVIES_SELECTED_SORT_INDEX_KEY, index);
      editor.commit();
    }
    Application.refresh();
  }

  public ScoreType getScoreType() {
    synchronized (this.preferencesLock) {
      final String value = this.preferences.getString(SCORE_TYPE_KEY, null);
      if (value == null) {
        return ScoreType.RottenTomatoes;
      }
      return ScoreType.valueOf(value);
    }
  }

  public void setScoreType(final ScoreType scoreType) {
    synchronized (this.preferencesLock) {
      final SharedPreferences.Editor editor = this.preferences.edit();
      editor.putString(SCORE_TYPE_KEY, scoreType.toString());
      editor.commit();
    }
  }

  public boolean isAutoUpdateEnabled() {
    synchronized (this.preferencesLock) {
      return this.preferences.getBoolean(AUTO_UPDATED_ENABLED_KEY, false);
    }
  }

  public void setAutoUpdateEnabled(final boolean enabled) {
    synchronized (this.preferencesLock) {
      final SharedPreferences.Editor editor = this.preferences.edit();
      editor.putBoolean(AUTO_UPDATED_ENABLED_KEY, enabled);
      editor.commit();
    }
  }

  public List<Movie> getMovies() {
    return this.dataProvider.getMovies();
  }

  public List<Theater> getTheaters() {
    return this.dataProvider.getTheaters();
  }

  public static List<FavoriteTheater> getFavoriteTheaters() {
    return Collections.emptyList();
  }

  public static String getTrailer(final Movie movie) {
    final String trailer = TrailerCache.getTrailer(movie);
    if (!isNullOrEmpty(trailer)) {
      return trailer;
    }

    return UpcomingCache.getTrailer(movie);
  }

  public Score getScore(final Movie movie) {
    return this.scoreCache.getScore(getMovies(), movie);
  }

  public List<Review> getReviews(final Movie movie) {
    return this.scoreCache.getReviews(getMovies(), movie);
  }

  public static List<String> getCast(final Movie movie) {
    if (!movie.getCast().isEmpty()) {
      return movie.getCast();
    }

    return UpcomingCache.getCast(movie);
  }

  private final static byte[] EMPTY_BYTES = new byte[0];

  public static byte[] getPoster(final Movie movie) {
    byte[] bytes = PosterCache.getPoster(movie);
    if (size(bytes) > 0) {
      return bytes;
    }
    bytes = UpcomingCache.getPoster(movie);
    if (size(bytes) > 0) {
      return bytes;
    }
    bytes = LargePosterCache.getPoster(movie);
    if (size(bytes) > 0) {
      return bytes;
    }
    return EMPTY_BYTES;
  }

  public static File getPosterFile_safeToCallFromBackground(final Movie movie) {
    File file = PosterCache.getPosterFile_safeToCallFromBackground(movie);
    if (file != null && file.exists()) {
      return file;
    }

    file = UpcomingCache.getPosterFile_safeToCallFromBackground(movie);
    if (file != null && file.exists()) {
      return file;
    }

    file = LargePosterCache.getPosterFile_safeToCallFromBackground(movie);
    if (file != null && file.exists()) {
      return file;
    }

    return null;
  }

  public String getSynopsis(final Movie movie) {
    final Collection<String> options = new ArrayList<String>();
    if (!isNullOrEmpty(movie.getSynopsis())) {
      options.add(movie.getSynopsis());
    }
    if (options.isEmpty() || Locale.getDefault().getLanguage().equals(Locale.ENGLISH.getLanguage())) {
      final Score score = getScore(movie);
      if (score != null && !isNullOrEmpty(score.getSynopsis())) {
        options.add(score.getSynopsis());
      }
      final String synopsis = UpcomingCache.getSynopsis(movie);
      if (!isNullOrEmpty(synopsis)) {
        options.add(synopsis);
      }
    }
    String bestOption = "";
    for (final String s : options) {
      if (s.length() > bestOption.length()) {
        bestOption = s;
      }
    }
    return bestOption;
  }

  public static String getIMDbAddress(final Movie movie) {
    String result = movie.getIMDbAddress();
    if (!isNullOrEmpty(result)) {
      return result;
    }

    result = IMDbCache.getIMDbAddress(movie);
    if (!isNullOrEmpty(result)) {
      return result;
    }

    result = UpcomingCache.getIMDbAddress(movie);
    if (!isNullOrEmpty(result)) {
      return result;
    }

    return "";
  }

  public void prioritizeMovie(final Movie movie) {
    if (movie == null) {
      return;
    }
    this.posterCache.prioritizeMovie(movie);
    this.scoreCache.prioritizeMovie(getMovies(), movie);
    this.trailerCache.prioritizeMovie(movie);
    this.upcomingCache.prioritizeMovie(movie);
  }

  public List<Theater> getTheatersShowingMovie(final Movie movie) {
    final List<Theater> result = new ArrayList<Theater>();
    for (final Theater theater : getTheaters()) {
      if (theater.getMovieTitles().contains(movie.getCanonicalTitle())) {
        result.add(theater);
      }
    }
    return result;
  }

  public List<Movie> getMoviesAtTheater(final Theater theater) {
    final List<Movie> result = new ArrayList<Movie>();
    for (final Movie movie : getMovies()) {
      if (theater.getMovieTitles().contains(movie.getCanonicalTitle())) {
        result.add(movie);
      }
    }
    return result;
  }

  public List<Performance> getPerformancesForMovieAtTheater(final Movie movie, final Theater theater) {
    return this.dataProvider.getPerformancesForMovieInTheater(movie, theater);
  }

  public static void reportLocationForAddress(final Location location, final String address) {
    UserLocationCache.reportLocationForAddress(location, address);
  }

  public List<Movie> getUpcomingMovies() {
    return this.upcomingCache.getMovies();
  }

  public LargePosterCache getLargePosterCache() {
    return this.largePosterCache;
  }
}
