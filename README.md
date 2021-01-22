# OpenWrtScripts

Welcome! What you're seeing is the small project I've been working in for a couple of months, the file wlan_ network_switcher.sh it's a 2.4ghz WLAN network switcher script that switches between 3 networks on the basis of a defined priority and internet access at the moment it's checked. It also detects and tries to fix internet and DNS problems.

The other file, 24_wifi_button_trigger.sh is a script that replaces the default function of the WiFi button the OpenWrt device has. It turns it into a 2.4ghz radio enabler (I only have 5ghz devices so I turn the 2.4ghz radio off by default): when you press the button the 2.4ghz radio is enabled for 15 minutes and then disabled again. Pressing the button while the 2.4ghz radio is enabled does not do anything.
