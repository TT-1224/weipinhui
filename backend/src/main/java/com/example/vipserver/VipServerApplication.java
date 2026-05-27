package com.example.vipserver;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.example.vipserver.mapper")
public class VipServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(VipServerApplication.class, args);
        System.out.println("=========================================");
        System.out.println("  唯品会仿制后端服务启动成功!");
        System.out.println("  访问地址: http://localhost:8080");
        System.out.println("  API文档: http://localhost:8080/api/goods/list");
        System.out.println("=========================================");
    }
}
