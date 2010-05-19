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

#define ArrayLength(x) (sizeof(x)/sizeof(*(x)))

#define ONE_MINUTE (60.0)
#define ONE_HOUR   (60.0 * ONE_MINUTE)
#define ONE_DAY    (24.0 * ONE_HOUR)
#define TWO_DAYS   (2.0 * ONE_DAY)
#define THREE_DAYS (3.0 * ONE_DAY)
#define ONE_WEEK   (7.0 * ONE_DAY)
#define TWO_WEEKS  (2.0 * ONE_WEEK)
#define ONE_YEAR   (365.0 * ONE_DAY)
#define ONE_MONTH  (ONE_YEAR / 12.0)

#define property_definition(x) static NSString* x ## _key = @#x; @synthesize x


#define SMALL_POSTER_HEIGHT 99.0f
//#define FULL_SCREEN_POSTER_HEIGHT 460
//#define FULL_SCREEN_POSTER_WIDTH 310

#define CACHE_LIMIT (30.0 * ONE_DAY)

#define LocalizedString(key, comment) [MetasyntacticSharedApplication localizedString:key]

#define AbstractMethod { @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil]; }

#define BITS_ARE_SET(value, mask) (((value) & (mask)) == (mask))
#define CLEAR_BITS(value, mask) ((value) & ~(mask))
#define SET_BITS(value, mask) ((value) | (mask))
