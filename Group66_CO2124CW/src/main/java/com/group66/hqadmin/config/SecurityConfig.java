package com.group66.hqadmin.config;

import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;


@Configuration
@EnableWebSecurity // Good practice to include this
public class SecurityConfig {

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                // 1. Force HTTPS on 8443
               // .requiresChannel(channel -> channel.anyRequest().requiresSecure())

                .authorizeHttpRequests(auth -> auth
                        // Make sure "/" and "/api/login" are truly open
                        .requestMatchers("/", "/api/login", "/login", "/WEB-INF/jsp/**", "/static/**", "/favicon.ico", "/api/departments", "/api/assignments").permitAll()
                        // Require HR role for destructive/sensitive actions if you want extra safety here
                        //.requestMatchers(HttpMethod.DELETE, "/api/employees/**").hasRole("HR")
                        .anyRequest().authenticated()
                )

                .exceptionHandling(eh -> eh
                        .authenticationEntryPoint((request, response, authException) -> {
                            // This is what the JS "fetch" will catch to show the login box
                            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                            response.setContentType("application/json");
                            response.getWriter().write("{\"error\": \"Please log in first.\"}");
                        })
                )

                .formLogin(form -> form.disable())
                .httpBasic(basic -> basic.disable()) // Disable the browser's popup login

                .logout(logout -> logout
                        .logoutUrl("/logout") // This must match your JS fetch URL
                        .logoutSuccessUrl("/") // Where to go after logout
                        .invalidateHttpSession(true) // Kill the session
                        .deleteCookies("JSESSIONID") // Delete the "memory" cookie
                        .permitAll()
                );

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}