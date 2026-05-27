package com.example.vipserver.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.vipserver.common.JwtUtil;
import com.example.vipserver.mapper.UserMapper;
import com.example.vipserver.pojo.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private JwtUtil jwtUtil;

    // MD5加密
  private String md5(String input) {
    try {
      MessageDigest md = MessageDigest.getInstance("MD5");
      byte[] digest = md.digest(input.getBytes());
      StringBuilder sb = new StringBuilder();
      for (byte b : digest) {
        sb.append(String.format("%02x", b));
      }
      return sb.toString();
    } catch (NoSuchAlgorithmException e) {
      throw new RuntimeException("MD5加密失败", e);
    }
  }

  // 登录
  public String login(String phone, String password) {
    LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
    wrapper.eq(User::getPhone, phone);
    User user = userMapper.selectOne(wrapper);

    if (user == null) {
      throw new RuntimeException("用户不存在");
    }

    // MD5密码比对
    if (!md5(password).equals(user.getPassword())) {
      throw new RuntimeException("密码错误");
    }

    return jwtUtil.generateToken(user.getId(), user.getPhone());
  }

    // 注册
    public void register(String phone, String password, String nickname) {
        // 检查手机号是否已存在
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getPhone, phone);
        Long count = userMapper.selectCount(wrapper);
        if (count > 0) {
            throw new RuntimeException("手机号已被注册");
        }

        User user = new User();
        user.setPhone(phone);
        user.setPassword(md5(password));
        user.setNickname(nickname != null ? nickname : "用户" + phone.substring(7));
        user.setStatus(1);
        userMapper.insert(user);
    }

    // 根据ID获取用户信息
    public User getUserById(Long userId) {
        return userMapper.selectById(userId);
    }

    // 更新用户资料
    public void updateProfile(Long userId, String avatar, String username, String email) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        if (avatar != null) user.setAvatar(avatar);
        if (username != null) user.setNickname(username);
        if (email != null) user.setEmail(email);
        userMapper.updateById(user);
    }
}
