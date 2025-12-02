"""User agent detection for mobile/desktop device detection.

This module provides utilities to detect mobile devices based on user agent strings,
testing against known patterns for various mobile devices and browsers.
"""

import re
from typing import Literal

# Known mobile user agent patterns
# Based on common mobile device and browser patterns
MOBILE_PATTERNS = [
    # iOS devices
    r"iPhone",
    r"iPod",
    r"iPad",
    r"iOS",
    # Android devices
    r"Android",
    r"Mobile.*Android",
    # Windows Phone
    r"Windows Phone",
    r"Windows Mobile",
    # BlackBerry
    r"BlackBerry",
    r"BB10",
    # Mobile browsers
    r"Mobile Safari",
    r"Opera Mini",
    r"Opera Mobi",
    r"Mobile.*Firefox",
    r"Mobile.*Chrome",
    # Tablet patterns (often treated as mobile for UI purposes)
    r"Tablet",
    r"Kindle",
    r"Silk",
    # Other mobile indicators
    r"Mobile",
    r"webOS",
    r"Palm",
    r"Fennec",  # Firefox Mobile
    r"Maemo",
    r"Symbian",
    r"J2ME",
    r"MIDP",
    r"CLDC",
    # Specific mobile browsers
    r"UCWEB",  # UC Browser
    r"UCBrowser",
    r"MicroMessenger",  # WeChat
    r"QQBrowser.*Mobile",
    r"Baiduspider.*mobile",
    # Screen size indicators (often in mobile UAs)
    r"wv",  # WebView
    r"Mobile.*wv",
]

# Desktop patterns (to explicitly identify desktop)
DESKTOP_PATTERNS = [
    r"Windows NT",
    r"Macintosh",
    r"Linux.*x86_64",
    r"X11.*Linux",
    r"Win64",
    r"WOW64",
]

# Compiled regex patterns for performance
_MOBILE_REGEX = re.compile("|".join(f"({pattern})" for pattern in MOBILE_PATTERNS), re.IGNORECASE)
_DESKTOP_REGEX = re.compile("|".join(f"({pattern})" for pattern in DESKTOP_PATTERNS), re.IGNORECASE)


def is_mobile_device(user_agent: str | None) -> bool:
    """Detect if user agent represents a mobile device.

    Tests against known patterns for various mobile devices including:
    - iOS devices (iPhone, iPad, iPod)
    - Android devices
    - Windows Phone
    - BlackBerry
    - Mobile browsers (Mobile Safari, Opera Mini, etc.)
    - Tablets (Kindle, etc.)

    Args:
        user_agent: User agent string from HTTP request header

    Returns:
        True if user agent matches mobile device patterns, False otherwise

    Examples:
        >>> is_mobile_device("Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)")
        True
        >>> is_mobile_device("Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        False
        >>> is_mobile_device("Mozilla/5.0 (Linux; Android 10; SM-G973F)")
        True
    """
    if not user_agent:
        return False

    user_agent_lower = user_agent.lower()

    # Check for mobile patterns
    if _MOBILE_REGEX.search(user_agent_lower):
        return True

    # Additional check: if it contains "Mobile" but not desktop patterns
    if "mobile" in user_agent_lower:
        # Make sure it's not a desktop browser with "Mobile" in the name
        if not _DESKTOP_REGEX.search(user_agent_lower):
            return True

    return False


def is_desktop_device(user_agent: str | None) -> bool:
    """Detect if user agent represents a desktop device.

    Args:
        user_agent: User agent string from HTTP request header

    Returns:
        True if user agent matches desktop device patterns, False otherwise
    """
    if not user_agent:
        return True  # Default to desktop if no UA

    user_agent_lower = user_agent.lower()

    # Check for explicit desktop patterns
    if _DESKTOP_REGEX.search(user_agent_lower):
        # Make sure it's not a mobile device
        if not _MOBILE_REGEX.search(user_agent_lower):
            return True

    # If no mobile patterns found and has desktop-like structure
    if not _MOBILE_REGEX.search(user_agent_lower):
        # Common desktop browser indicators
        if any(
            browser in user_agent_lower
            for browser in ["chrome", "firefox", "safari", "edge", "opera"]
        ):
            # Make sure it's not mobile
            if "mobile" not in user_agent_lower:
                return True

    return False


def detect_device_type(user_agent: str | None) -> Literal["mobile", "desktop"]:
    """Detect device type from user agent.

    Args:
        user_agent: User agent string from HTTP request header

    Returns:
        "mobile" if mobile device detected, "desktop" otherwise
    """
    if is_mobile_device(user_agent):
        return "mobile"
    return "desktop"


def get_view_context(
    view_type: Literal["list", "detail"],
    user_agent: str | None = None,
) -> str:
    """Get composite view context based on view type and user agent.

    Args:
        view_type: Type of view ("list" or "detail")
        user_agent: Optional user agent string for device detection

    Returns:
        Composite context string (e.g., "list_mobile", "detail_desktop")
    """
    device_type = detect_device_type(user_agent)
    return f"{view_type}_{device_type}"
