#!/usr/bin/env bash
#
# installs and configures chromium (on wayland)
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES='chromium'

function configure_chromium {

pacman-need

# These flags will be included by default for every call of "chromium"
# The flags given here are intended to force chromium to run using wayland.
cat <<-EOF > /etc/chromium-flags.conf
--ozone-platform=wayland
--ignore-gpu-blocklist
--enable-gpu-rasterization
--enable-zero-copy
--enable-features=AcceleratedVideoDecodeLinuxGL,WaylandPerSurfaceScale,WaylandUiScale
--gtk-version=4
EOF

# Reference: https://www.chromium.org/administrators/linux-quick-start/
mkdir -p /etc/chromium/policies
mkdir -p /etc/chromium/policies/managed
mkdir -p /etc/chromium/policies/recommended

# These settings are optional. They act as the default but can be changed by a user.
cat <<EOF > /etc/chromium/policies/recommended/default.json
{
}
EOF

# These settings are forced!
cat <<EOF > /etc/chromium/policies/managed/default.json
{
    "AutofillAddressEnabled": false,
    "AutofillCreditCardEnabled": false,
    "BrowserAddPersonEnabled": false,
    "BuiltInDnsClientEnabled": false,
    "BrowserLabsEnabled": false,
    "BrowserSignin": 0,
    "ClearBrowsingDataOnExitList": [
        "browsing_history",
        "download_history",
        "cookies_and_other_site_data",
        "cached_images_and_files",
        "password_signin",
        "autofill",
        "site_settings",
        "hosted_app_data"
    ],
    "CloudReportingEnabled": false,
    "DefaultBrowserSettingEnabled": false,
    "DefaultGeolocationSetting": 2,
    "DefaultNotificationsSetting": 2,
    "DefaultSearchProviderEnabled": true,
    "DefaultSearchProviderSearchURL": "https://duckduckgo.com/?q={searchTerms}&kp=-2&kl=us-en&kae=d&k1=-1",
    "ExtensionInstallForcelist": [
        "ddkjiahejlhfcafbddmgiahcphecmpfh",
        "nngceckbapebfimnlniiiahkandclblb",
        "ldpochfccmkkmhdbclfhpagapcfdljkj",
        "mnjggcdmjocbbbhaepdhchncahnbgone",
        "edibdbjcniadpccecjdfdjjppcpchdlm"
    ],
    "ForceEphemeralProfiles": false,
    "GenAiDefaultSettings": 2,
    "GenAISmartGroupingSettings": 2,
    "HomepageIsNewTabPage": false,
    "HomepageLocation": "https://duckduckgo.com/?kp=%2D2&kl=us%2Den&k1=%2D1&kae=d",
    "MetricsReportingEnabled": false,
    "NewTabPageLocation": "https://duckduckgo.com/?kp=%2D2&kl=us%2Den&k1=%2D1&kae=d",
    "PasswordManagerEnabled": false,
    "PromptForDownloadLocation": true,
    "RestoreOnStartup": 4,
    "RestoreOnStartupURLs":[
        "https://duckduckgo.com/?kp=%2D2&kl=us%2Den&k1=%2D1&kae=d"
    ],
    "SafeBrowsingExtendedReportingEnabled": false,    
    "ShowHomeButton": true,
    "ShoppingListEnabled": false,
    "SiteSearchSettings": [],
    "SearchSuggestEnabled": false,
    "SyncDisabled": true,
    "UrlKeyedAnonymizedDataCollectionEnabled" :false
}
EOF

}

require_root
configure_chromium


