package com.application.auction.util;

public final class PrivacyMaskingUtil {
    private static final String DEFAULT_DISPLAY_NAME = "Nguoi dung";

    private PrivacyMaskingUtil() {
    }

    public static String maskDisplayName(String value) {
        if (value == null || value.isBlank()) {
            return DEFAULT_DISPLAY_NAME;
        }

        String trimmed = value.trim();
        if (trimmed.contains("@")) {
            return maskEmail(trimmed);
        }
        if (trimmed.length() <= 2) {
            return trimmed.charAt(0) + "***";
        }
        return trimmed.substring(0, Math.min(4, trimmed.length())) + "***";
    }

    public static String maskEmail(String value) {
        if (value == null || value.isBlank()) {
            return "";
        }

        String trimmed = value.trim();
        int atIndex = trimmed.indexOf('@');
        if (atIndex <= 0) {
            return maskDisplayName(trimmed);
        }

        String localPart = trimmed.substring(0, atIndex);
        String domain = trimmed.substring(atIndex);
        int visibleLength = Math.min(3, localPart.length());
        return localPart.substring(0, visibleLength) + "***" + domain;
    }
}
