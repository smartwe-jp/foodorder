package com.hisanweb.flutter_plugin_msprinter.orderInfo;

import java.util.List;


public class CategoryVos {

    private String categoryName;

    private List<LineVos> lineVos;

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setLineVos(List<LineVos> lineVos) {
        this.lineVos = lineVos;
    }

    public List<LineVos> getLineVos() {
        return lineVos;
    }

}