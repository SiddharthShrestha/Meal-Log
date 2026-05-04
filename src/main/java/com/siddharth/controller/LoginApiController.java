package com.siddharth.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * Servlet implementation class LoginApiController
 */
@WebServlet("/api/login")
public class LoginApiController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public LoginApiController() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.setContentType("application/json");
        response.getWriter().print("{\"message\": \"Use POST for login\"}");

	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		
		
		//set response type
		
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        //get parameter
        String email=request.getParameter("email");
        String password=request.getParameter("password");
        
        if(email.equals("admin")&&password.equals("admin")) {
            HttpSession session = request.getSession();
            session.setAttribute("email", email);

            response.setStatus(HttpServletResponse.SC_OK);
            out.print("{\"message\": \"Login successful\"}");
        }else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"message\": \"Invalid credentials\"}");
        }
	
	}

}