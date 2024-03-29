package org.metasyntactic.activities;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.metasyntactic.data.Movie;
import org.metasyntactic.data.Performance;
import org.metasyntactic.data.Theater;
import org.metasyntactic.utilities.MovieViewUtilities;

import android.content.Intent;
import android.content.res.Resources;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Parcelable;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

/**
 * @author mjoshi@google.com (Megha Joshi)
 */
public class TheaterDetailsActivity extends AbstractNowPlayingListActivity {
  private static final String THEATER_DETAIL_ENTRIES_KEY = TheaterDetailsActivity.class.getSimpleName() + ".SEARCH_KEY";

  /**
   * Called when the activity is first created.
   */
  private Theater theater;
  private Iterable<Movie> movies = new ArrayList<Movie>();
  private List<TheaterDetailEntry> theaterDetailEntries = new ArrayList<TheaterDetailEntry>();

  private void onCreateWorker() {
    theater = getIntent().getExtras().getParcelable("theater");
    movies = getService().getMoviesAtTheater(theater);
    populateTheaterDetailEntries();
    final TextView titleView = (TextView) findViewById(R.id.theater);
    titleView.setText(theater.getName());
    final View linearLayout = findViewById(R.id.header);
    final ImageView ratingImage = (ImageView) findViewById(R.id.ratingImage);
    final Resources res = getResources();
    if (getService().isFavoriteTheater(theater)) {
      ratingImage.setImageDrawable(res.getDrawable(R.drawable.rate_star_big_on));
    } else {
      ratingImage.setImageDrawable(res.getDrawable(R.drawable.rate_star_big_off));
    }
    linearLayout.setClickable(true);
    linearLayout.setOnClickListener(new View.OnClickListener() {
      public void onClick(final View view) {
        if (getService().isFavoriteTheater(theater)) {
          ratingImage.setImageDrawable(res.getDrawable(R.drawable.rate_star_big_off));
          getService().removeFavoriteTheater(theater);
        } else {
          ratingImage.setImageDrawable(res.getDrawable(R.drawable.rate_star_big_on));
          getService().addFavoriteTheater(theater);
        }
      }
    });
    setListAdapter(new TheaterDetailsAdapter());
  }

  @Override
  public void onCreate(final Bundle bundle) {
    super.onCreate(bundle);
    setContentView(R.layout.theaterdetails);
    onCreateWorker();
  }

  @Override
  public Map<String, Object> onRetainNonConfigurationInstance() {
    final Map<String, Object> state = super.onRetainNonConfigurationInstance();
    state.put(THEATER_DETAIL_ENTRIES_KEY, theaterDetailEntries);
    return state;
  }

  @Override
  protected void onListItemClick(final ListView listView, final View view, final int position, final long id) {
    final Intent intent = theaterDetailEntries.get(position).intent;
    if (intent != null) {
      startActivity(intent);
    }
    super.onListItemClick(listView, view, position, id);
  }

  @SuppressWarnings("unchecked")
  public List<TheaterDetailEntry> getLastNonConfigurationInstanceValue() {
    final Map<String, Object> state = getLastNonConfigurationInstance();
    if (state == null) {
      return null;
    }
    return (List<TheaterDetailEntry>) state.get(THEATER_DETAIL_ENTRIES_KEY);
  }

  private void populateTheaterDetailEntries() {
    theaterDetailEntries = getLastNonConfigurationInstanceValue();

    if (theaterDetailEntries == null || theaterDetailEntries.isEmpty()) {
      theaterDetailEntries = new ArrayList<TheaterDetailEntry>();
      final Resources res = getResources();
      {
        // Add map header
        final TheaterDetailEntry entry = new TheaterDetailEntry(res.getString(R.string.map), null,
            TheaterDetailItemType.HEADER, null, null, false);
        theaterDetailEntries.add(entry);
      }
      {
        // Add map
        final String address = theater.getAddress() + ", " + theater.getLocation().getCity();
        final Intent mapIntent = new Intent("android.intent.action.VIEW", Uri.parse("geo:0,0?q=" + address));
        final Drawable mapIcon = res.getDrawable(R.drawable.sym_action_map);
        final TheaterDetailEntry entry = new TheaterDetailEntry(address, null, TheaterDetailItemType.ACTION, mapIcon,
            mapIntent, true);
        theaterDetailEntries.add(entry);
      }
      {
        // Add phone header
        final TheaterDetailEntry entry = new TheaterDetailEntry(res.getString(R.string.call), null,
            TheaterDetailItemType.HEADER, null, null, false);
        theaterDetailEntries.add(entry);
      }
      {
        // Add phone
        final String phone = theater.getPhoneNumber();
        final Intent phoneIntent = new Intent("android.intent.action.DIAL", Uri
            .parse("tel:" + theater.getPhoneNumber()));
        final Drawable phoneIcon = res.getDrawable(R.drawable.sym_action_call);
        final TheaterDetailEntry entry = new TheaterDetailEntry(phone, null, TheaterDetailItemType.ACTION, phoneIcon,
            phoneIntent, true);
        theaterDetailEntries.add(entry);
      }
      {
        // Add warning
        if (getService().isStale(theater)) {
          final TheaterDetailEntry entry = new TheaterDetailEntry(getService().getShowtimesRetrievedOnString(theater,
              getResources()), null, TheaterDetailItemType.WARNING, null, null, false);
          theaterDetailEntries.add(entry);
        }
        // Add showtimes header
        final TheaterDetailEntry entry = new TheaterDetailEntry(res.getString(R.string.now_showing), null,
            TheaterDetailItemType.HEADER, null, null, false);
        theaterDetailEntries.add(entry);
      }
      // Add movies
      for (final Movie movie : movies) {
        final String movieTitle = movie.getDisplayTitle();
        final List<Performance> list = getService().getPerformancesForMovieAtTheater(movie, theater);
        String performance = performanceString(list);
        final Intent movieIntent = new Intent();
        movieIntent.setClass(this, MovieDetailsActivity.class);
        movieIntent.putExtra("movie", (Parcelable) movie);
        final TheaterDetailEntry entry = new TheaterDetailEntry(movieTitle, performance, TheaterDetailItemType.DATA,
            null, movieIntent, true);
        theaterDetailEntries.add(entry);
      }
    }
  }

  private String performanceString(final List<Performance> list) {
    String performance = "";
    if (!list.isEmpty()) {
      for (final Performance aList : list) {
        performance += aList.getTime() + ", ";
      }
      performance = performance.substring(0, performance.length() - 2);
    }
    return performance;
  }

  private class TheaterDetailsAdapter extends BaseAdapter {
    private final LayoutInflater inflater;

    @Override
    public boolean areAllItemsEnabled() {
      return false;
    }

    @Override
    public boolean isEnabled(final int position) {
      return theaterDetailEntries.get(position).isSelectable();
    }

    private TheaterDetailsAdapter() {
      // Cache the LayoutInflate to avoid asking for a new one each time.
      inflater = LayoutInflater.from(TheaterDetailsActivity.this);
    }

    public View getView(final int position, View convertView, final ViewGroup viewGroup) {
      final TheaterDetailEntry entry = theaterDetailEntries.get(position);
      switch (entry.type) {
      case DATA:
        convertView = getDataView(entry);
        break;
      case HEADER:
        convertView = getHeaderView(entry);
        break;
      case ACTION:
        convertView = getActionView(entry);
        break;
      case WARNING:
        convertView = getWarningView(entry);
        break;
      }
      return convertView;
    }

    private View getWarningView(final TheaterDetailEntry entry) {
      final View convertView = inflater.inflate(R.layout.warning_item, null);
      final TextView warningText = (TextView) convertView.findViewById(R.id.warningText);
      warningText.setText(entry.data);
      return convertView;
    }

    private View getActionView(final TheaterDetailEntry entry) {
      final View convertView = inflater.inflate(R.layout.theaterdetails_icon_item, null);
      final TextView actionView = (TextView) convertView.findViewById(R.id.data);
      actionView.setText(entry.data);
      final ImageView actionIcon = (ImageView) convertView.findViewById(R.id.icon);
      actionIcon.setImageDrawable(entry.icon);
      return convertView;
    }

    private View getHeaderView(final TheaterDetailEntry entry) {
      final View convertView = inflater.inflate(R.layout.headerview, null);
      final TextView headerView = (TextView) convertView.findViewById(R.id.name);
      headerView.setText(entry.data);
      return convertView;
    }

    private View getDataView(final TheaterDetailEntry entry) {
      final View convertView = inflater.inflate(R.layout.theaterdetails_item, null);
      final TextView movieView = (TextView) convertView.findViewById(R.id.label);
      movieView.setText(entry.data);
      final TextView showtimesView = (TextView) convertView.findViewById(R.id.data);
      showtimesView.setText(entry.data2);
      return convertView;
    }

    public int getCount() {
      return theaterDetailEntries.size();
    }

    public Object getItem(final int position) {
      return theaterDetailEntries.get(position);
    }

    public long getItemId(final int position) {
      return position;
    }
  }

  @Override
  public boolean onCreateOptionsMenu(final Menu menu) {
    menu.add(0, MovieViewUtilities.MENU_MOVIES, 0, R.string.menu_movies).setIcon(R.drawable.ic_menu_home).setIntent(
        new Intent(this, NowPlayingActivity.class));
    menu.add(0, MovieViewUtilities.MENU_SETTINGS, 0, R.string.settings).setIcon(android.R.drawable.ic_menu_preferences)
        .setIntent(new Intent(this, SettingsActivity.class).putExtra("from_menu", "yes"));
    return super.onCreateOptionsMenu(menu);
  }

  private enum TheaterDetailItemType {
    DATA, ACTION, HEADER, WARNING
  }

  private static class TheaterDetailEntry {
    private final TheaterDetailItemType type;
    private final Drawable icon;
    private final boolean selectable;
    private final String data;
    private final Intent intent;
    private final String data2;

    private TheaterDetailEntry(final String data, final String data2, final TheaterDetailItemType type,
        final Drawable icon, final Intent intent, final boolean selectable) {
      this.data = data;
      this.data2 = data2;
      this.type = type;
      this.icon = icon;
      this.selectable = selectable;
      this.intent = intent;
    }

    public boolean isSelectable() {
      return selectable;
    }
  }
}
