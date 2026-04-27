package com.group66.hqadmin;

import com.group66.hqadmin.entity.AppUser;
import com.group66.hqadmin.repository.AppUserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootApplication
public class Group66Co2124CwApplication {

    public static void main(String[] args) {
        SpringApplication.run(Group66Co2124CwApplication.class, args);
    }

    @Bean
    CommandLineRunner initDatabase(AppUserRepository repository, PasswordEncoder encoder) {
        return args -> {
            if (repository.findByUsername("admin").isEmpty()) {
                AppUser admin = new AppUser();
                admin.setUsername("admin");
                // Important: Use the password encoder!
                admin.setPassword(encoder.encode("admin123"));
                admin.setRole("HR"); // This matches your SecurityConfig .hasRole("HR")
                repository.save(admin);
                System.out.println("Admin user 'admin' created with password 'admin123'");
            }
            else {
                System.out.println("Admin found in  database with username 'admin and password 'admin123'");
            }
            // Create HR Admin (Full Access)
            if (repository.findByUsername("admin_hr").isEmpty()) {
                AppUser hr = new AppUser();
                hr.setUsername("admin_hr");
                hr.setPassword(encoder.encode("hr123"));
                hr.setRole("HR"); // SecurityConfig looks for .hasRole("HR")
                repository.save(hr);
            }
            else {
                System.out.println("HR found in  database with username 'admin_hr and password 'hr123'");
            }

            // Create Manager (Read-Only Access)
            if (repository.findByUsername("manager_user").isEmpty()) {
                AppUser manager = new AppUser();
                manager.setUsername("manager_user");
                manager.setPassword(encoder.encode("mgr123"));
                manager.setRole("MANAGER"); // SecurityConfig looks for .hasRole("MANAGER")
                repository.save(manager);
            }
            else {
                System.out.println("Manager found in  database with username 'manager_user' and password 'mgr123'");
            }

        };
    }


}

/*"C:\Program Files\Java\jdk-21\bin\keytool.exe" -genkeypair -alias hqadmin -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore keystore.p12 -validity 365*/
//https://localhost:8443/login


//make view employee epage to view a specififc employee
// make filter option to filter by name or by dept