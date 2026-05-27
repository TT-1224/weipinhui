package com.example.vipserver.common;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RuntimeException.class)
    public Map<String, Object> handleRuntimeException(RuntimeException e) {
        log.error("业务异常: {}", e.getMessage());
        Map<String, Object> result = new HashMap<>();
        result.put("code", -1);
        result.put("msg", e.getMessage());
        return result;
    }

    @ExceptionHandler(Exception.class)
    public Map<String, Object> handleException(Exception e) {
        log.error("系统异常: ", e);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 500);
        result.put("msg", "服务器内部错误");
        return result;
    }
}
