#!/usr/bin/env bash
#
# installs and configures firefox
#
# refs:
# - https://stackoverflow.com/questions/72572010/arch-linux-how-to-install-firefox-extensions-with-no-install-rdf-file-silent
# - https://github.com/mozilla/policy-templates
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES='firefox gnu-free-fonts'

function configure_firefox {

pacman-need

$LOG -i "Creating policy for firefox..."
mkdir -p /etc/firefox/policies
cat <<-EOF > /etc/firefox/policies/policies.json
{
  "policies": {
    "Extensions": {
      "Install": [
        "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/istilldontcareaboutcookies/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/uaswitcher/latest.xpi"
      ]
    },
    "ExtensionUpdate": true,
    "DisableTelemetry": true,
    "DisableFirefoxStudies": true,
    "DisablePocket": true,
    "DisableFormHistory": true,
    "DisableMasterPasswordCreation": true,
    "DisableSetDesktopBackground": true,
    "DontCheckDefaultBrowser": true,
    "DisableFirefoxAccounts": true,
    "ManualAppUpdateOnly": true,
    "NoDefaultBookmarks": true,
    "OfferToSaveLogins": false,
    "PasswordManagerEnabled": false,
    "PrimaryPassword": false,
    "PromptForDownloadLocation": true,
    "SearchSuggestEnabled": false,
    "NetworkPrediction": false,
    "EnableTrackingProtection": {
      "Value": true,
      "Locked": false,
      "Cryptomining": true,
      "Fingerprinting": true,
      "EmailTracking": true,
      "Exceptions": []
    },
    "Homepage": {
      "URL": "https://www.startpage.com/do/mypage.pl?prfe=bfe55790e6ccda528ded0d3ab65712978f45d8dca24e0d80ee49db5824772c71b5752aa5c8fe4a9f635faaacf193065860fcb67f7a2b59a9321c4ecfd0ef999abeb91493c97e777843abccee",
      "Locked": false,
      "Additional": [],
      "StartPage": "homepage"
    },
    "FirefoxHome": {
      "Search": false,
      "TopSites": false,
      "SponsoredTopSites": false,
      "Highlights": false,
      "Pocket": false,
      "SponsoredPocket": false,
      "Snippets": false,
      "Locked": true
    },
    "UserMessaging": {
      "WhatsNew": false,
      "ExtensionRecommendations": false,
      "FeatureRecommendations": false,
      "UrlbarInterventions": false,
      "SkipOnboarding": false,
      "MoreFromMozilla": false,
      "Locked": true
    },
    "SanitizeOnShutdown": {
      "Cache": true,
      "Cookies": true,
      "Downloads": false,
      "FormData": true,
      "History": true,
      "Sessions": true,
      "SiteSettings": true,
      "OfflineApps": true,
      "Locked": true
    },
    "Permissions": {
      "Camera": {
        "Allow": [],
        "Block": [],
        "BlockNewRequests": true,
        "Locked": false
      },
      "Microphone": {
        "Allow": [],
        "Block": [],
        "BlockNewRequests": true,
        "Locked": false
      },
      "Location": {
        "Allow": [],
        "Block": [],
        "BlockNewRequests": true,
        "Locked": false
      },
      "Notifications": {
        "Allow": [],
        "Block": [],
        "BlockNewRequests": true,
        "Locked": true
      },
      "Autoplay": {
        "Allow": [],
        "Block": [],
        "Default": "block-audio-video",
        "Locked": false
      }
    },
    "FirefoxSuggest": {
      "WebSuggestions": false,
      "SponsoredSuggestions": false,
      "ImproveSuggest": false,
      "Locked": true
    }
  }
}
EOF

}

require_root
configure_firefox
