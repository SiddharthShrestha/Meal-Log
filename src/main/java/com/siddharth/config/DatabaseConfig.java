package com.siddharth.config;
import java.sql.Connection;
import java.sql.DriverManager;
public class DatabaseConfig {
    private static final String DB_NAME  = "meallog";
    private static final String URL      = "jdbc:mysql://127.0.0.1:3306/" + DB_NAME
                                           + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USER     = "root";
    private static final String PASSWORD = "";
    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("Database Connected!");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL Driver not found: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Database connection failed: " + e.getMessage());
            e.printStackTrace();
        }
        return conn;
    }
}




