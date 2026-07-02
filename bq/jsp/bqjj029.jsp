<%@ page contentType = "text/html;charset=cp950"%> 
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool"%>
<%! public static final String _AppId = "BQJJ029"; %>
<%@ include file="../../jsp/dzjjmain_M.jsp" %>

<%
aajcYCATool aaTool = new aajcYCATool();

//取得系統時間
dejc308 de308 = new dejc308();
String date_Beg = de308.getCrntDateWFmt1();
String time_Beg = "0000";
String date_End = de308.getCrntDateWFmt1();
String time_End = de308.getCrntTimeFmt1().substring(0, 4);

//測試資料
//Map[] machines = mockMachines();

//抓機台資訊
String sql = "SELECT * FROM TABLE(DB.IPQ3PB('', '"+date_Beg+"','"+time_Beg+"','"+date_End+"','"+time_End+"')) a WHERE a.應稼動時間 >0 ORDER BY a.MACHINEID";
Map[] machines = new dejcQueryDAO(_dsCom).getDatas(sql.toString());
%>


<!DOCTYPE html>
<%@page import="java.math.BigDecimal"%>
<html lang="zh-Hant">
<head>
    <title>機台停機管理（JSP function）</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-slate-50 font-sans">
<div class="max-w-md mx-auto py-4 px-1">
    <h2 class="text-xl font-bold text-slate-800 mb-4 text-center">今日機台停機狀態</h2>
    <div class="flex flex-col gap-3">
    <%
        // 用 function 產生三筆模擬資料
        for(Map<String,Object> m : machines) {
            String 機台碼 = aaTool.getStr(m.get("MACHINEID"));
            int 應稼動時間 = aaTool.getBigDecimal(m.get("應稼動時間")).intValue();
            int 停機時間 = aaTool.getBigDecimal(m.get("停機時間")).intValue();
            double 稼動率 = 應稼動時間 > 0 ? (應稼動時間-停機時間)*100 / 應稼動時間 : 0;
            int 停機次數 = aaTool.getBigDecimal(m.get("停機次數")).intValue();
            int 正在停機時間 = aaTool.getBigDecimal(m.get("正在停機時間")).intValue();
            boolean isStop = 正在停機時間 > 0;
             
            // 狀態/顏色判斷
            String status, color, textColor, borderColor, utilColor;
            String stopTime;
            if(!isStop && 稼動率 >= 50) {
                status = "運轉中";
                color = "bg-green-500";
                textColor = "text-white";
                borderColor = "border-green-500";
                stopTime = "-";
                utilColor = "text-green-600";
            } else if(稼動率 < 50 && 正在停機時間 <= 30) {
                status = "稼動率太低";
                color = "bg-yellow-500";
                textColor = "text-white";
                borderColor = "border-yellow-500";
                stopTime = 正在停機時間 + " 分鐘";
                utilColor = "text-yellow-500";
            } else if(正在停機時間 <= 30) {
                status = "正常停機";
                color = "bg-orange-400";
                textColor = "text-slate-800";
                borderColor = "border-orange-400";
                stopTime = 正在停機時間 + " 分鐘";
                utilColor = "text-orange-500";
            } else {
                status = "異常停機";
                color = "bg-red-500";
                textColor = "text-white";
                borderColor = "border-red-500";
                stopTime = 正在停機時間 + " 分鐘";
                utilColor = "text-red-500";
            } 
    %>
        <div class="bg-white rounded-xl shadow flex flex-col px-4 py-3 border-l-8 <%= borderColor %>">
            <div class="flex items-center justify-between mb-1">
                <div class="text-base font-semibold text-slate-800"><%= 機台碼 %></div>
                <span class="px-2 py-0.5 text-xs rounded <%= color %> <%= textColor %> font-bold"><%= status %></span>
            </div>
            <div class="flex justify-between text-sm mb-1">
                <span class="text-slate-500">停機次數</span>
                <span class="font-semibold text-slate-700"><%= 停機次數 %></span>
            </div>
            <div class="flex justify-between text-sm mb-1">
                <span class="text-slate-500">目前停機</span>
                <span class="font-semibold <%= utilColor %>"><%= stopTime %></span>
            </div>
            <div class="flex justify-between text-sm">
                <span class="text-slate-500">稼動率</span>
                <span class="font-semibold <%= utilColor %>"><%= 稼動率 %>%</span>
            </div>
        </div>
    <%
        }
    %>
    </div>
</div>
</body>
</html>

<%! // JSP 頁面 function，產生 3 筆模擬資料
    public static Map[] mockMachines() {
        Map[] machines = new Map[3];
        // M01 運轉中
        Map<String,Object> m1 = new HashMap();
        m1.put("MACHINEID", "M01");			//機台碼
        m1.put("應稼動時間", 880);
        m1.put("停機時間", 400);	
        m1.put("停機次數", 2);	
        m1.put("正在停機時間", 0);	
        machines[0] = m1;
        // M02 正常停機
        Map<String,Object> m2 = new HashMap();
        m2.put("MACHINEID", "M02");
        m2.put("應稼動時間", 720);
        m2.put("停機時間", 400);	
        m2.put("停機次數", 1);
        m2.put("正在停機時間", 11);
        machines[1] = m2;
        // M03 異常停機
        Map<String,Object> m3 = new HashMap();
        m3.put("MACHINEID", "M03");
        m3.put("應稼動時間", 900);
        m3.put("停機時間", 400);	
        m3.put("停機次數", 5);
        m3.put("正在停機時間", 38);
        machines[2] = m3;
         
        return machines;
    }
%>