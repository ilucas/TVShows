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

#import "Miso.h"
#import "JSON.h"
#import "RegexKitLite.h"

@implementation Miso

@synthesize delegate;

- (id)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenAccepted:) name:MPOAuthNotificationAccessTokenReceived object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenAccepted:) name:MPOAuthNotificationAccessTokenRefreshed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenRejected:) name:MPOAuthNotificationAccessTokenRejected object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenRejected:) name:MPOAuthNotificationErrorHasOccurred object:nil];
        oauthAPI = [MPOAuthAPI alloc];
	}
	return self;
}

- (void)authorizeWithKey:(NSString *)aKey secret:(NSString *)aSecret
{
    // Try to empty credentials, because we may be already signed in
    [self authorizeWithKey:aKey secret:aSecret userName:@"" andPassword:@""];
}

- (void)authorizeWithKey:(NSString *)aKey secret:(NSString *)aSecret userName:(NSString *)anUserName andPassword:(NSString *)aPassword
{
    NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:
                                 aKey, kMPOAuthCredentialConsumerKey,
                                 aSecret, kMPOAuthCredentialConsumerSecret,
                                 anUserName, kMPOAuthCredentialUsername,
                                 aPassword, kMPOAuthCredentialPassword,
                                 nil];
    [oauthAPI initWithCredentials:credentials andBaseURL:[NSURL URLWithString:@"https://gomiso.com/"]];
}

- (void)accessTokenAccepted:(NSNotification *)inNotification {
    if (delegate && [delegate respondsToSelector:@selector(authenticationEnded:)]) {
        [delegate authenticationEnded:YES];
    }
}

- (void)accessTokenRejected:(NSNotification *)inNotification {
    if (delegate && [delegate respondsToSelector:@selector(authenticationEnded:)]) {
        [delegate authenticationEnded:NO];
    }
}

- (NSDictionary *)userDetails
{
    return [self jsonValue:[oauthAPI dataForMethod:@"http://gomiso.com/api/oauth/v1/users/show.json"]];
}

- (NSDictionary *)showWithQuery:(NSString *)query
{
    NSString *queryClean = [[[[[query stringByReplacingOccurrencesOfRegex:@"\\s+uk\\s*" withString:@""]
                               stringByReplacingOccurrencesOfRegex:@"\\s+us\\s*" withString:@""]
                              stringByReplacingOccurrencesOfRegex:@"\\s+\\(.*\\)\\s*" withString:@""]
                             stringByReplacingOccurrencesOfRegex:@"\\s+and\\s+" withString:@" "]
                            stringByReplacingOccurrencesOfRegex:@"\\s+&\\s+" withString:@" "];
    
    NSArray *params = [MPURLRequestParameter parametersFromString:[NSString stringWithFormat:@"q=%@&kind=TvShow", queryClean]];
    
    return [self jsonValue:[oauthAPI dataForMethod:@"http://gomiso.com/api/oauth/v1/media.json"
                                    withParameters:params]];
}

- (NSDictionary *)favoritedShows
{
    return [self jsonValue:[oauthAPI dataForMethod:@"http://gomiso.com/api/oauth/v1/media/favorites.json"]];
}

- (NSDictionary *)favoriteShow:(NSString *)showId
{
    NSURL *requestURL = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/media/favorites.json"];
    NSArray *params = [MPURLRequestParameter parametersFromString:[NSString stringWithFormat:@"media_id=%@", showId]];

    MPOAuthURLRequest *aRequest = [[MPOAuthURLRequest alloc] initWithURL:requestURL andParameters:params];
    [aRequest setHTTPMethod:@"POST"];

    MPOAuthAPIRequestLoader *loader = [[MPOAuthAPIRequestLoader alloc] initWithRequest:aRequest];
    [loader setCredentials:[oauthAPI credentials]];
    [loader loadSynchronously:YES];

    [loader autorelease];
    [aRequest release];

    return [self jsonValue:[loader data]];
}

- (NSDictionary *)unfavoriteShow:(NSString *)showId
{
    NSURL *requestURL = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/media/favorites.json"];
    NSArray *params = [MPURLRequestParameter parametersFromString:[NSString stringWithFormat:@"media_id=%@", showId]];
    
    MPOAuthURLRequest *aRequest = [[MPOAuthURLRequest alloc] initWithURL:requestURL andParameters:params];
    [aRequest setHTTPMethod:@"DELETE"];
    
    MPOAuthAPIRequestLoader *loader = [[MPOAuthAPIRequestLoader alloc] initWithRequest:aRequest];
    [loader setCredentials:[oauthAPI credentials]];
    [loader loadSynchronously:YES];
    
    [loader autorelease];
    [aRequest release];
    
    return [self jsonValue:[loader data]];
}

- (NSDictionary *)checkingsForUser:(NSString *)userId andShow:(NSString *)showId
{
    NSArray *params = [MPURLRequestParameter parametersFromString:[NSString stringWithFormat:@"user_id=%@&media_id=%@", userId, showId]];
    
    return [self jsonValue:[oauthAPI dataForMethod:@"http://gomiso.com/api/oauth/v1/checkins.json"
                                    withParameters:params]];
}

- (NSDictionary *)addCheckingForShow:(NSString *)showId withSeasonNum:(NSString *)season episodeNum:(NSString *)episode
{
    NSURL *requestURL = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/checkins.json"];
    NSArray *params = [MPURLRequestParameter parametersFromString:[NSString stringWithFormat:@"media_id=%@&season_num=%@&episode_num=%@", showId, season, episode]];
    
    MPOAuthURLRequest *aRequest = [[MPOAuthURLRequest alloc] initWithURL:requestURL andParameters:params];
    [aRequest setHTTPMethod:@"POST"];
    
    MPOAuthAPIRequestLoader *loader = [[MPOAuthAPIRequestLoader alloc] initWithRequest:aRequest];
    [loader setCredentials:[oauthAPI credentials]];
    [loader loadSynchronously:YES];
    
    [loader autorelease];
    [aRequest release];
    
    return [self jsonValue:[loader data]];
}

- (void)forgetAuthorization
{
    [oauthAPI discardCredentials];
}

- (NSDictionary *)jsonValue:(NSData *)data
{
    if (data) {
        NSString *string = [[[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding] autorelease];
        return [string JSONValue];
    } else {
        return nil;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [oauthAPI release];
    [super dealloc];
}

@end
