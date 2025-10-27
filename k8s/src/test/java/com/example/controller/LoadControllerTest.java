package com.example.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(LoadController.class)
class LoadControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void pingEndpointShouldReturnPong() throws Exception {
        mockMvc.perform(get("/api/ping"))
                .andExpect(status().isOk())
                .andExpect(content().contentType("application/json"))
                .andExpect(jsonPath("$.message").value("pong"))
                .andExpect(jsonPath("$.timestamp").exists());
    }

    @Test
    void cpuLoadEndpointShouldReturnSuccessResponse() throws Exception {
        mockMvc.perform(get("/api/cpu-load")
                .param("duration", "10")
                .param("threads", "1"))
                .andExpect(status().isOk())
                .andExpect(content().contentType("application/json"))
                .andExpect(jsonPath("$.status").value("CPU load generated"))
                .andExpect(jsonPath("$.duration_ms").value(10))
                .andExpect(jsonPath("$.threads").value(1))
                .andExpect(jsonPath("$.execution_time_ms").exists());
    }

    @Test
    void memoryLoadEndpointShouldReturnSuccessResponse() throws Exception {
        mockMvc.perform(get("/api/memory-load")
                .param("sizeMB", "1"))
                .andExpect(status().isOk())
                .andExpect(content().contentType("application/json"))
                .andExpect(jsonPath("$.status").value("Memory load generated"))
                .andExpect(jsonPath("$.allocated_mb").value(1))
                .andExpect(jsonPath("$.execution_time_ms").exists())
                .andExpect(jsonPath("$.array_length").value(1));
    }

    @Test
    void cpuLoadWithDefaultParametersShouldWork() throws Exception {
        mockMvc.perform(get("/api/cpu-load"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.duration_ms").value(100))
                .andExpect(jsonPath("$.threads").value(1));
    }

    @Test
    void memoryLoadWithDefaultParametersShouldWork() throws Exception {
        mockMvc.perform(get("/api/memory-load"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.allocated_mb").value(10));
    }
}