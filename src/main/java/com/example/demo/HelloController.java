package com.example.demo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    private final Integer serverNumber;

    private HelloController(@Value("${server-number}") final int serverNumber) {
        this.serverNumber = serverNumber;
    }

    @GetMapping("/hello")
    public String hello() {
        return "This is " + serverNumber + "th Server";
    }
}
