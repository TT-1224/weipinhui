package com.example.vipserver.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.example.vipserver.mapper.AddressMapper;
import com.example.vipserver.pojo.Address;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AddressService {

    @Autowired
    private AddressMapper addressMapper;

    /**
     * 获取用户所有收货地址列表
     */
    public List<Address> getAddressList(Long userId) {
        LambdaQueryWrapper<Address> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Address::getUserId, userId)
              .orderByDesc(Address::getIsDefault)
              .orderByDesc(Address::getCreateTime);
        return addressMapper.selectList(wrapper);
    }

    /**
     * 获取用户默认地址
     */
    public Address getDefaultAddress(Long userId) {
        LambdaQueryWrapper<Address> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Address::getUserId, userId)
              .eq(Address::getIsDefault, 1);
        return addressMapper.selectOne(wrapper);
    }

    /**
     * 根据ID获取单个地址详情
     */
    public Address getAddressById(Long id, Long userId) {
        LambdaQueryWrapper<Address> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Address::getId, id)
              .eq(Address::getUserId, userId);
        return addressMapper.selectOne(wrapper);
    }

    /**
     * 新增收货地址
     */
    @Transactional
    public void addAddress(Address address) {
        if (address.getIsDefault() != null && address.getIsDefault() == 1) {
            this.clearDefaultAddress(address.getUserId());
        }
        if (address.getIsDefault() == null) {
            address.setIsDefault(0);
        }
        addressMapper.insert(address);
    }

    /**
     * 修改收货地址
     */
    @Transactional
    public void updateAddress(Long userId, Address address) {
        if (address.getIsDefault() != null && address.getIsDefault() == 1) {
            this.clearDefaultAddress(userId);
        }
        LambdaUpdateWrapper<Address> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Address::getId, address.getId())
              .eq(Address::getUserId, userId);
        addressMapper.update(address, wrapper);
    }

    /**
     * 删除收货地址
     */
    @Transactional
    public void deleteAddress(Long id, Long userId) {
        LambdaQueryWrapper<Address> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Address::getId, id)
              .eq(Address::getUserId, userId);

        Address existing = addressMapper.selectOne(wrapper);
        if (existing != null) {
            addressMapper.deleteById(id);

            if (existing.getIsDefault() == 1) {
                autoSetNewDefaultAddress(userId);
            }
        }
    }

    /**
     * 设置默认地址（核心逻辑：同一用户只能有一个默认地址）
     */
    @Transactional
    public void setDefaultAddress(Long addressId, Long userId) {
        this.clearDefaultAddress(userId);

        LambdaUpdateWrapper<Address> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Address::getId, addressId)
              .eq(Address::getUserId, userId)
              .set(Address::getIsDefault, 1);
        addressMapper.update(null, wrapper);
    }

    /**
     * 清除用户的所有默认地址标记
     */
    private void clearDefaultAddress(Long userId) {
        LambdaUpdateWrapper<Address> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Address::getUserId, userId)
              .eq(Address::getIsDefault, 1)
              .set(Address::getIsDefault, 0);
        addressMapper.update(null, wrapper);
    }

    /**
     * 自动设置新的默认地址（当原默认地址被删除后）
     */
    private void autoSetNewDefaultAddress(Long userId) {
        LambdaQueryWrapper<Address> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Address::getUserId, userId)
              .orderByDesc(Address::getCreateTime)
              .last("LIMIT 1");
        
        Address newestAddress = addressMapper.selectOne(wrapper);
        if (newestAddress != null) {
            this.setDefaultAddress(newestAddress.getId(), userId);
        }
    }
}
