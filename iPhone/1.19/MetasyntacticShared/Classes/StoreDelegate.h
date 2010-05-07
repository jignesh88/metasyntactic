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

@protocol StoreDelegate<NSObject>

- (NSString*) sendUnlockRequest:(AbstractUnlockRequest*) unlockRequest;


- (AbstractUnlockRequest*) createUnlockRequest:(id<StoreItem>) item
                         transactionIdentifier:(NSString*) transactionIdentifier
                                       receipt:(NSString*) receipt
                                   transaction:(SKPaymentTransaction*) transaction;


- (AbstractUnlockRequest*) createBypassStoreRequest:(id<StoreItem>) item
                                             reason:(NSString*) reason;

- (void) reportUnlockResult:(UnlockResult*) unlockResult;

- (id<StoreItem>) itemForItunesIdentifier:(NSString*) itunesIdentifier;

@end
