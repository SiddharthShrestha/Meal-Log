package com.siddharth.util;

import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class EmailUtil {

    private static final String FROM_EMAIL   = "siddharthnathshrestha@gmail.com";
    private static final String APP_PASSWORD = "xbamxmrjvjrenxmd";

    public static void sendOtpEmail(String toEmail, String otp) throws Exception {

        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            "smtp.gmail.com");
        props.put("mail.smtp.port",            "587");
        props.put("mail.smtp.ssl.trust",       "smtp.gmail.com");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(FROM_EMAIL, "MealLog"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("Your MealLog password reset code");
        message.setContent(buildEmailBody(otp), "text/html; charset=utf-8");

        Transport.send(message);
    }

    private static String buildEmailBody(String otp) {
        return "<!DOCTYPE html>" +
            "<html><head><meta charset='UTF-8'/></head>" +
            "<body style='margin:0;padding:0;background:#faf8f3;font-family:sans-serif;'>" +
            "<div style='max-width:480px;margin:40px auto;background:#ffffff;border-radius:14px;border:1.5px solid #d4e0d9;overflow:hidden;'>" +

            "<div style='background:#3d7a5a;padding:28px 32px;text-align:center;'>" +
            "<span style='font-size:1.6rem;font-weight:700;color:#ffffff;letter-spacing:1px;'>MealLog</span>" +
            "</div>" +

            "<div style='padding:36px 32px;text-align:center;'>" +
            "<h2 style='margin:0 0 10px;font-size:1.2rem;color:#1a1f1c;'>Password Reset Code</h2>" +
            "<p style='margin:0 0 28px;font-size:0.92rem;color:#6b7a72;line-height:1.6;'>" +
            "Use the code below to reset your MealLog password. " +
            "It expires in <strong>10 minutes</strong> and can only be used once." +
            "</p>" +
            "<div style='display:inline-block;padding:20px 40px;background:#f0fff4;border:2px dashed #a8d5bc;border-radius:12px;margin-bottom:28px;'>" +
            "<span style='font-size:2.2rem;font-weight:700;color:#3d7a5a;letter-spacing:10px;'>" + otp + "</span>" +
            "</div>" +
            "<p style='margin:0;font-size:0.78rem;color:#a0a0a0;line-height:1.5;'>" +
            "If you didn't request this, you can safely ignore this email." +
            "</p>" +
            "</div>" +

            "<div style='background:#f5f9f7;padding:16px 32px;text-align:center;border-top:1px solid #d4e0d9;'>" +
            "<span style='font-size:0.78rem;color:#a0a0a0;'>MealLog &mdash; your personal nutrition tracker</span>" +
            "</div>" +

            "</div></body></html>";
    }
}