package com.example.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@RestController
@RequestMapping("/api")
public class LoadController {

    private final Random random = new Random();

    /**
     * Endpoint để tạo CPU load cho việc test autoscaling
     */
    @GetMapping("/cpu-load")
    public Map<String, Object> cpuLoad(
            @RequestParam(defaultValue = "100") int duration,
            @RequestParam(defaultValue = "1") int threads) {
        
        long startTime = System.currentTimeMillis();
        
        // Tạo CPU load bằng cách chạy vòng lặp tính toán
        for (int i = 0; i < threads; i++) {
            new Thread(() -> {
                long endTime = System.currentTimeMillis() + duration;
                while (System.currentTimeMillis() < endTime) {
                    // Tính toán phức tạp để tạo CPU load
                    Math.sqrt(random.nextDouble() * 1000000);
                    Math.pow(random.nextDouble(), random.nextDouble());
                }
            }).start();
        }
        
        long executionTime = System.currentTimeMillis() - startTime;
        
        Map<String, Object> response = new HashMap<>();
        response.put("status", "CPU load generated");
        response.put("duration_ms", duration);
        response.put("threads", threads);
        response.put("execution_time_ms", executionTime);
        
        return response;
    }

    /**
     * Endpoint để tạo memory load
     */
    @GetMapping("/memory-load")
    public Map<String, Object> memoryLoad(
            @RequestParam(defaultValue = "10") int sizeMB) {
        
        long startTime = System.currentTimeMillis();
        
        // Tạo array để chiếm bộ nhớ
        byte[][] memoryHolder = new byte[sizeMB][];
        for (int i = 0; i < sizeMB; i++) {
            memoryHolder[i] = new byte[1024 * 1024]; // 1 MB
            // Fill với random data
            for (int j = 0; j < memoryHolder[i].length; j++) {
                memoryHolder[i][j] = (byte) random.nextInt();
            }
        }
        
        long executionTime = System.currentTimeMillis() - startTime;
        
        Map<String, Object> response = new HashMap<>();
        response.put("status", "Memory load generated");
        response.put("allocated_mb", sizeMB);
        response.put("execution_time_ms", executionTime);
        response.put("array_length", memoryHolder.length);
        
        return response;
    }

    /**
     * Endpoint đơn giản để test response time
     */
    @GetMapping("/ping")
    public Map<String, String> ping() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "pong");
        response.put("timestamp", String.valueOf(System.currentTimeMillis()));
        return response;
    }
}
