package com.example;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:testdb",
    "spring.jpa.hibernate.ddl-auto=create-drop"
})
class MainTest {

    @Test
    void contextLoads() {
        // This test will fail if the application context cannot start
        // It's a basic smoke test to ensure Spring Boot application loads correctly
    }
}