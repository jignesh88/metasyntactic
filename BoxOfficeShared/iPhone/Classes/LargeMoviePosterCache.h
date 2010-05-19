// Copyright 2010 Cyrus Najmabadi
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or (at your option) any
// later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

@interface LargeMoviePosterCache : AbstractMovieCache {
@private
  // Shared amongst multiple threads.
  AutoreleasingMutableDictionary* yearToMovieNames;
  AutoreleasingMutableDictionary* yearToTitleToPosterUrls;

  BOOL updated;
}

+ (LargeMoviePosterCache*) cache;

+ (NSDictionary*) processPosterListings:(XmlElement*) posterListingsElement;

- (void) update;

- (UIImage*) posterForMovie:(Movie*) movie loadFromDisk:(BOOL) loadFromDisk;
- (UIImage*) smallPosterForMovie:(Movie*) movie loadFromDisk:(BOOL) loadFromDisk;

- (UIImage*) posterForMovie:(Movie*) movie index:(NSInteger) index loadFromDisk:(BOOL) loadFromDisk;
- (BOOL) posterExistsForMovie:(Movie*) movie index:(NSInteger) index;

- (void) downloadFirstPosterForMovie:(Movie*) movie;
- (void) downloadAllPostersForMovie:(Movie*) movie;
- (BOOL) allPostersDownloadedForMovie:(Movie*) movie;
- (NSInteger) posterCountForMovie:(Movie*) movie;

@end
