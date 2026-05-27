package com.example.vipserver.config;

import com.example.vipserver.common.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.util.StringUtils;

@Component
public class JwtInterceptor implements HandlerInterceptor {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // OPTIONS请求直接放行（跨域预检）
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        // 排除登录/注册接口和公开的商品接口
        String uri = request.getRequestURI();
        if (uri.contains("/login") || uri.contains("/register")
            || uri.contains("/goods/search") || uri.contains("/goods/list")
            || uri.contains("/goods/detail") || uri.contains("/goods/categories")
            || uri.contains("/goods/recommended")) {
            return true;
        }

        // 验证Token
        String authHeader = request.getHeader("Authorization");
        if (!StringUtils.hasText(authHeader) || !authHeader.startsWith("Bearer ")) {
            response.setStatus(401);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":401,\"msg\":\"未登录或Token已过期\"}");
            return false;
        }

        String token = authHeader.replace("Bearer ", "");
        if (!jwtUtil.validateToken(token)) {
            response.setStatus(401);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":401,\"msg\":\"Token无效或已过期\"}");
            return false;
        }

        // ✅ 解析Token并注入用户信息到Request属性（供Controller使用）
        Long userId = jwtUtil.getUserIdFromToken(token);
        String username = jwtUtil.getUsernameFromToken(token);
        System.out.println("🔍 [JwtInterceptor] Token验证通过 - userId: " + userId + ", username: " + username);
        
        request.setAttribute("currentUserId", userId);
        request.setAttribute("currentUserPhone", username);

        return true;
    }
}
