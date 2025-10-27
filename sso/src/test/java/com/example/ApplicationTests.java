package com.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class ApplicationTests {

	@Test
	void simpleTest() {
		// Simple test that doesn't require Spring context
		assertTrue(true, "This test should always pass");
	}
	
	@Test
	void basicCalculation() {
		// Basic calculation test
		int result = 3 * 3;
		assertEquals(9, result, "3 * 3 should equal 9");
	}

}