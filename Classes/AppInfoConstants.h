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

// Import the "secrets"
#import "AppSecretConstants.h"

// Define log level
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

#define TVShowsAppDomain            @"com.victorpimentel.TVShows2"
#define TVShowsHelperDomain         @"com.victorpimentel.TVShowsHelper"

#define TVShowsWebsite              @"http://tvshowsapp.com/"
#define TVShowsSupport              @"http://support.tvshowsapp.com/"
#define TVShowsBlog                 @"http://blog.tvshowsapp.com/"
#define TVShowsTwitter              @"http://twitter.com/TVShows2/"
#define TVShowsDonations            @"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=2PARRGESKRQJ6&item_name=TVShows2&item_number=TVShows2&currency_code=%@&lc=%@&bn=PP%%2dDonationsBF%%3abtn_donateCC_LG%%2egif%%3aNonHosted"
#define MisoWebsite                 @"http://gomiso.com/"

#define TVShowsAppcastURL           @"http://tvshowsapp.com/tvshows.xml"
#define TVShowsBetaAppcastURL       @"http://tvshowsapp.com/tvshows-beta.xml"

// Used in the Delegate methods so that we don't have to duplicate files.
#if PREFPANE
    #define CurrentBundleDomain     @"com.victorpimentel.TVShows2"
#elif HELPER_APP
    #define CurrentBundleDomain     @"com.victorpimentel.TVShowsHelper"
#endif

// This is for deciding whether to hide a warning or not
// If the user default is this, the warning will be shown
#define ShowWarning                 -1
