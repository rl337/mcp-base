"""Tests for user agent detection."""

import pytest

from mcp_base.user_agent import (
    detect_device_type,
    get_view_context,
    is_desktop_device,
    is_mobile_device,
)


class TestMobileDetection:
    """Tests for mobile device detection."""

    # Real-world mobile user agent strings
    MOBILE_USER_AGENTS = [
        # iPhone
        "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1",
        # iPad
        "Mozilla/5.0 (iPad; CPU OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1",
        "Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1",
        # Android phones
        "Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36",
        "Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Mobile Safari/537.36",
        "Mozilla/5.0 (Linux; Android 12; SM-S908B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.61 Mobile Safari/537.36",
        "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Mobile Safari/537.36",
        # Android tablets
        "Mozilla/5.0 (Linux; Android 10; SM-T860) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Safari/537.36",
        "Mozilla/5.0 (Linux; Android 11; Pixel C) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36",
        # Windows Phone
        "Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; Microsoft; Lumia 950) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Mobile Safari/537.36 Edge/13.10586",
        "Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; NOKIA; Lumia 920)",
        # BlackBerry
        "Mozilla/5.0 (BlackBerry; U; BlackBerry 9800; en) AppleWebKit/534.1+ (KHTML, like Gecko) Version/6.0.0.337 Mobile Safari/534.1+",
        "Mozilla/5.0 (BB10; Touch) AppleWebKit/537.35+ (KHTML, like Gecko) Version/10.3.3.2205 Mobile Safari/537.35+",
        # Opera Mobile
        "Opera/9.80 (Android; Opera Mini/7.5.33361/31.1448; U; en) Presto/2.8.119 Version/11.1010",
        "Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36 OPR/68.0.3618.104",
        # Mobile Firefox
        "Mozilla/5.0 (Mobile; rv:68.0) Gecko/68.0 Firefox/68.0",
        "Mozilla/5.0 (Android 10; Mobile; rv:91.0) Gecko/91.0 Firefox/91.0",
        # Kindle
        "Mozilla/5.0 (Linux; U; en-US) AppleWebKit/528.5+ (KHTML, like Gecko, Safari/528.5+) Version/4.0 Kindle/3.0 (screen 600x800; rotate)",
        # UC Browser
        "Mozilla/5.0 (Linux; U; Android 10; en-US; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/78.0.3904.108 UCBrowser/13.2.0.1305 Mobile Safari/537.36",
        # WeChat
        "Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/78.0.3904.108 Mobile Safari/537.36 MicroMessenger/8.0.0",
        # Generic mobile
        "Mozilla/5.0 (Mobile; rv:68.0) Gecko/68.0",
    ]

    @pytest.mark.parametrize("user_agent", MOBILE_USER_AGENTS)
    def test_mobile_detection(self, user_agent):
        """Test that known mobile user agents are detected as mobile."""
        assert is_mobile_device(user_agent), f"Failed to detect mobile: {user_agent}"

    def test_mobile_detection_none(self):
        """Test mobile detection with None user agent."""
        assert not is_mobile_device(None)

    def test_mobile_detection_empty(self):
        """Test mobile detection with empty user agent."""
        assert not is_mobile_device("")


class TestDesktopDetection:
    """Tests for desktop device detection."""

    # Real-world desktop user agent strings
    DESKTOP_USER_AGENTS = [
        # Windows
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59",
        "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        # macOS
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        # Linux
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Mozilla/5.0 (X11; Linux x86_64; rv:89.0) Gecko/20100101 Firefox/89.0",
        "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:89.0) Gecko/20100101 Firefox/89.0",
        # Chrome on desktop
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36",
        # Firefox on desktop
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0) Gecko/20100101 Firefox/108.0",
        "Mozilla/5.0 (X11; Linux x86_64; rv:108.0) Gecko/20100101 Firefox/108.0",
        # Edge on desktop
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.46",
        # Safari on desktop
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15",
    ]

    @pytest.mark.parametrize("user_agent", DESKTOP_USER_AGENTS)
    def test_desktop_detection(self, user_agent):
        """Test that known desktop user agents are detected as desktop."""
        assert is_desktop_device(user_agent), f"Failed to detect desktop: {user_agent}"

    def test_desktop_detection_none(self):
        """Test desktop detection with None user agent (defaults to desktop)."""
        assert is_desktop_device(None)

    def test_desktop_detection_empty(self):
        """Test desktop detection with empty user agent."""
        assert is_desktop_device("")


class TestDeviceTypeDetection:
    """Tests for device type detection."""

    def test_detect_mobile(self):
        """Test detecting mobile device type."""
        ua = "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15"
        assert detect_device_type(ua) == "mobile"

    def test_detect_desktop(self):
        """Test detecting desktop device type."""
        ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        assert detect_device_type(ua) == "desktop"

    def test_detect_default_desktop(self):
        """Test that None defaults to desktop."""
        assert detect_device_type(None) == "desktop"


class TestViewContext:
    """Tests for view context generation."""

    def test_get_list_mobile_context(self):
        """Test getting list mobile context."""
        ua = "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)"
        context = get_view_context("list", ua)
        assert context == "list_mobile"

    def test_get_list_desktop_context(self):
        """Test getting list desktop context."""
        ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        context = get_view_context("list", ua)
        assert context == "list_desktop"

    def test_get_detail_mobile_context(self):
        """Test getting detail mobile context."""
        ua = "Mozilla/5.0 (Android 10; SM-G973F)"
        context = get_view_context("detail", ua)
        assert context == "detail_mobile"

    def test_get_detail_desktop_context(self):
        """Test getting detail desktop context."""
        ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
        context = get_view_context("detail", ua)
        assert context == "detail_desktop"

    def test_get_context_default_desktop(self):
        """Test that None user agent defaults to desktop."""
        context = get_view_context("list", None)
        assert context == "list_desktop"

        context = get_view_context("detail", None)
        assert context == "detail_desktop"
