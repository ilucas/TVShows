/*
 *  This file is part of the TVShows 2 ("Phoenix") source code.
 *  http://github.com/victorpimentel/TVShows/
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import <Cocoa/Cocoa.h>
#import "MPOAuth.h"

@protocol MisoDelegate;

@interface Miso : NSObject
{
    MPOAuthAPI *oauthAPI;
}

@property (nonatomic, assign) id<MisoDelegate> delegate;

- (void)authorizeWithKey:(NSString *)aKey secret:(NSString *)aSecret;
- (void)authorizeWithKey:(NSString *)aKey secret:(NSString *)aSecret userName:(NSString *)anUserName andPassword:(NSString *)aPassword;

- (void)accessTokenAccepted:(NSNotification *)inNotification;
- (void)accessTokenRejected:(NSNotification *)inNotification;

- (NSDictionary *)userDetails;

- (NSDictionary *)showWithQuery:(NSString *)query;

- (NSDictionary *)favoritedShows;
- (NSDictionary *)favoriteShow:(NSString *)showId;
- (NSDictionary *)unfavoriteShow:(NSString *)showId;

- (NSDictionary *)checkingsForUser:(NSString *)userId andShow:(NSString *)showId;
- (NSDictionary *)addCheckingForShow:(NSString *)showId withSeasonNum:(NSString *)season episodeNum:(NSString *)episode;

- (void)forgetAuthorization;

- (NSDictionary *)jsonValue:(NSData *)data;

@end

@protocol MisoDelegate <NSObject>
@optional
- (void)authenticationEnded:(BOOL)authenticated;
@end
