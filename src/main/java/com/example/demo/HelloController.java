package com.example.demo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
//    private final Integer serverNumber;
//
//    private HelloController(@Value("${server-number}") final int serverNumber) {
//        this.serverNumber = serverNumber;
//    }
//
//    @GetMapping("/hello")
//    public String hello() {
//        return "This is " + serverNumber + "th Server";
//    }

    private final String port;
    private HelloController(@Value("${server.port}") final String port) {
        this.port = port;
    }

    @GetMapping("/port")
    public String port() {
        return port;
    }
}


