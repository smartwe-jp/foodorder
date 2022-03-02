package com.hisanweb.flutter_plugin_msprinter.orderInfo;

import java.util.List;


public class OrderMenuList {

    private String orderId;
    private String orderDate;
    private String payPrice;
    private String shopName;
    private String telephone;
    private String shopAddress;
    private String signValue;
    private String excludingTax;
    private String tax;
    private List<CategoryVos> categoryVos;

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderDate(String orderDate) {
        this.orderDate = orderDate;
    }

    public String getOrderDate() {
        return orderDate;
    }

    public void setPayPrice(String payPrice) {
        this.payPrice = payPrice;
    }

    public String getPayPrice() {
        return payPrice;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public String getShopName() {
        return shopName;
    }

    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }

    public String getTelephone() {
        return telephone;
    }

    public void setShopAddress(String shopAddress) {
        this.shopAddress = shopAddress;
    }

    public String getShopAddress() {
        return shopAddress;
    }

    public void setSignValue(String signValue) {
        this.signValue = signValue;
    }

    public String getSignValue() {
        return signValue;
    }

    public void setExcludingTax(String excludingTax) {
        this.excludingTax = excludingTax;
    }

    public String getExcludingTax() {
        return excludingTax;
    }

    public void setTax(String tax) {
        this.tax = tax;
    }

    public String getTax() {
        return tax;
    }

    public void setCategoryVos(List<CategoryVos> categoryVos) {
        this.categoryVos = categoryVos;
    }

    public List<CategoryVos> getCategoryVos() {
        return categoryVos;
    }

}