package com.siddharth.util;

/**
 * ValidationUtil - Reusable validation and formatting methods
 * used across controllers to avoid code duplication.
 */
public class ValidationUtil {

    // ── String checks ────────────────────────────────────────────────────────

    /** Returns true if the string is null or empty after trimming. */
    public static boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    /** Returns the trimmed string, or empty string if null. */
    public static String clean(String value) {
        return value == null ? "" : value.trim();
    }

    // ── Email ────────────────────────────────────────────────────────────────

    /** Returns true if the email matches a basic valid format. */
    public static boolean isValidEmail(String email) {
        if (isEmpty(email)) return false;
        return email.trim().matches("\\S+@\\S+\\.\\S+");
    }

    // ── Password ─────────────────────────────────────────────────────────────

    /** Returns true if password is at least 6 characters. */
    public static boolean isValidPassword(String password) {
        if (isEmpty(password)) return false;
        return password.trim().length() >= 6;
    }

    /** Returns true if password and confirm password match. */
    public static boolean passwordsMatch(String password, String confirm) {
        if (isEmpty(password) || isEmpty(confirm)) return false;
        return password.equals(confirm);
    }

    // ── Name ─────────────────────────────────────────────────────────────────

    /** Returns true if the full name contains only letters and spaces. */
    public static boolean isValidName(String name) {
        if (isEmpty(name)) return false;
        return name.trim().matches("[a-zA-Z\\s]+");
    }

    // ── Numbers ──────────────────────────────────────────────────────────────

    /** Returns true if the string is a valid positive number. */
    public static boolean isPositiveNumber(String value) {
        if (isEmpty(value)) return false;
        try {
            return Double.parseDouble(value.trim()) > 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /** Returns true if the string is a valid integer greater than zero. */
    public static boolean isPositiveInteger(String value) {
        if (isEmpty(value)) return false;
        try {
            return Integer.parseInt(value.trim()) > 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /** Safely parses a double, returns 0.0 if invalid. */
    public static double parseDouble(String value) {
        try {
            return Double.parseDouble(clean(value));
        } catch (NumberFormatException e) {
            return 0.0;
        }
    }

    /** Safely parses an int, returns 0 if invalid. */
    public static int parseInt(String value) {
        try {
            return Integer.parseInt(clean(value));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    // ── Macros ───────────────────────────────────────────────────────────────

    /** Returns true if all four macro values are valid positive numbers. */
    public static boolean isValidMacros(String calories, String protein,
                                        String carbs, String fats) {
        return isPositiveNumber(calories)
            && isPositiveNumber(protein)
            && isPositiveNumber(carbs)
            && isPositiveNumber(fats);
    }
}