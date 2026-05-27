package com.example.vipserver.controller;

import com.example.vipserver.common.Result;
import com.example.vipserver.pojo.Address;
import com.example.vipserver.service.AddressService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/address")
public class AddressController {

    @Autowired
    private AddressService addressService;

    /**
     * 获取地址列表
     */
    @GetMapping("/list")
    public Result<List<Address>> list(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        System.out.println("🔍 [AddressController] 获取地址列表 - userId: " + userId);
        
        List<Address> addresses = addressService.getAddressList(userId);
        System.out.println("🔍 [AddressController] 查询到地址数量: " + (addresses != null ? addresses.size() : 0));
        
        return Result.success(addresses);
    }

    /**
     * 获取默认地址（用于订单创建等场景）
     */
    @GetMapping("/default")
    public Result<Address> getDefault(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        Address defaultAddress = addressService.getDefaultAddress(userId);
        return Result.success(defaultAddress);
    }

    /**
     * 获取单个地址详情
     */
    @GetMapping("/{id}")
    public Result<Address> detail(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        Address address = addressService.getAddressById(id, userId);
        if (address == null) {
            return Result.error("地址不存在");
        }
        return Result.success(address);
    }

    /**
     * 新增地址
     */
    @PostMapping("/add")
    public Result<Void> add(@RequestBody Address address, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        
        if (address.getReceiverName() == null || address.getReceiverName().trim().isEmpty()) {
            return Result.error("请输入收件人姓名");
        }
        if (address.getReceiverPhone() == null || address.getReceiverPhone().trim().isEmpty()) {
            return Result.error("请输入联系电话");
        }
        if (address.getProvince() == null || address.getCity() == null || address.getDistrict() == null) {
            return Result.error("请选择省市区");
        }
        if (address.getDetailAddress() == null || address.getDetailAddress().trim().isEmpty()) {
            return Result.error("请输入详细地址");
        }
        
        address.setUserId(userId);
        addressService.addAddress(address);
        return Result.success(null);
    }

    /**
     * 修改地址
     */
    @PutMapping("/update")
    public Result<Void> update(@RequestBody Address address, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        
        if (address.getId() == null) {
            return Result.error("地址ID不能为空");
        }
        
        addressService.updateAddress(userId, address);
        return Result.success(null);
    }

    /**
     * 删除地址
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        addressService.deleteAddress(id, userId);
        return Result.success(null);
    }

    /**
     * 设置默认地址
     */
    @PutMapping("/setDefault/{id}")
    public Result<Void> setDefault(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        addressService.setDefaultAddress(id, userId);
        return Result.success(null);
    }
}
