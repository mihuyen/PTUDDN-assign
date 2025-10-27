package com.example;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import com.example.sso.SsoApplication;

@SpringBootTest(classes = SsoApplication.class)
class ApplicationTests {

	@Test
	void contextLoads() {
		// This test will pass as long as the Spring context loads successfully
	}

}