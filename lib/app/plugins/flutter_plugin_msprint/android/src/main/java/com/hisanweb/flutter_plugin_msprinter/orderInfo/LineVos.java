package com.hisanweb.flutter_plugin_msprinter.orderInfo;

import java.util.List;


public class LineVos {

    private String menuName;


    private String menuQty;
    private String menuNamePrintStr;



    private List<OptionVos> optionVos;

    public String getMenuName() {
        return menuName;
    }

    public void setMenuName(String menuName) {
        this.menuName = menuName;
    }

    public String getMenuQty() {
        return menuQty;
    }

    public void setMenuQty(String menuQty) {
        this.menuQty = menuQty;
    }

    public String getMenuNamePrintStr() {
        return menuNamePrintStr;
    }

    public void setMenuNamePrintStr(String menuNamePrintStr) {
        this.menuNamePrintStr = menuNamePrintStr;
    }

    public List<OptionVos> getOptionVos() {
        return optionVos;
    }

    public void setOptionVos(List<OptionVos> optionVos) {
        this.optionVos = optionVos;
    }
}