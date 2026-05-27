package com.example.vipserver.controller;

import com.example.vipserver.common.JwtUtil;
import com.example.vipserver.common.Result;
import com.example.vipserver.pojo.User;
import com.example.vipserver.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class AuthController {

    @Autowired
    private UserService userService;

    @Autowired
    private JwtUtil jwtUtil;

    // 登录
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> params) {
        String phone = params.get("phone");
        String password = params.get("password");

        if (phone == null || password == null) {
            return Result.error("手机号和密码不能为空");
        }

        try {
            String token = userService.login(phone, password);
            Long userId = jwtUtil.getUserIdFromToken(token);

            Map<String, Object> data = new HashMap<>();
            data.put("token", token);
            data.put("userId", userId);
            return Result.success(data);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }

    // 注册
    @PostMapping("/register")
    public Result<String> register(@RequestBody Map<String, String> params) {
        String phone = params.get("phone");
        String password = params.get("password");
        String nickname = params.get("nickname");

        if (phone == null || password == null) {
            return Result.error("手机号和密码不能为空");
        }
        if (password.length() < 6) {
            return Result.error("密码长度至少6位");
        }

        try {
            userService.register(phone, password, nickname);
            return Result.success("注册成功", null);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }

    // 获取当前用户信息（需要Token）
    @GetMapping("/info")
    public Result<User> getUserInfo(@RequestHeader("Authorization") String authHeader) {
        try {
            String token = authHeader.replace("Bearer ", "");
            Long userId = jwtUtil.getUserIdFromToken(token);
            User user = userService.getUserById(userId);
            if (user != null) {
                user.setPassword(null); // 不返回密码
            }
            return Result.success(user);
        } catch (Exception e) {
            return Result.error("无效的Token");
        }
    }

    // 更新用户资料（对应EditProfilePage）
    @PutMapping("/profile")
    public Result<String> updateProfile(@RequestHeader("Authorization") String authHeader,
                                        @RequestBody Map<String, String> params) {
        try {
            String token = authHeader.replace("Bearer ", "");
            Long userId = jwtUtil.getUserIdFromToken(token);
            userService.updateProfile(userId,
                    params.get("avatar"),
                    params.get("username"),
                    params.get("email"));
            return Result.success("更新成功", null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
