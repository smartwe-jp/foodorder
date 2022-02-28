package com.hisanweb.flutter_plugin_msprinter.orderInfo;

import java.util.List;


public class LineVos {

    private String menuName;

    private String menuQty;

    private List<OptionVos> optionVos;

    public void setMenuName(String menuName) {
        this.menuName = menuName;
    }

    public String getMenuName() {
        return menuName;
    }

    public void setMenuQty(String menuQty) {
        this.menuQty = menuQty;
    }

    public String getMenuQty() {
        return menuQty;
    }

    public void setOptionVos(List<OptionVos> optionVos) {
        this.optionVos = optionVos;
    }

    public List<OptionVos> getOptionVos() {
        return optionVos;
    }

}