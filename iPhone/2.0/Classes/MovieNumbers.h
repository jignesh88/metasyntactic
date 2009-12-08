// Copyright (C) 2008 Cyrus Najmabadi
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

@interface MovieNumbers : NSObject {
    NSString* identifier;
    NSString* canonicalTitle;
    NSInteger currentRank;
    NSInteger previousRank;
    NSInteger currentGross;
    NSInteger totalGross;
    NSInteger theaters;
    NSInteger days;
}

@property (copy) NSString* identifier;
@property (copy) NSString* canonicalTitle;
@property NSInteger currentRank;
@property NSInteger previousRank;
@property NSInteger currentGross;
@property NSInteger totalGross;
@property NSInteger theaters;
@property NSInteger days;

+ (MovieNumbers*) numbersWithDictionary:(NSDictionary*) dictionary;
+ (MovieNumbers*) numbersWithIdentifier:(NSString*) identifier
                                  title:(NSString*) title
                            currentRank:(NSInteger) currentRank
                           previousRank:(NSInteger) previousRank
                           currentGross:(NSInteger) currentGross
                             totalGross:(NSInteger) totalGross
                               theaters:(NSInteger) theaters
                                   days:(NSInteger) days;

- (NSDictionary*) dictionary;


@end