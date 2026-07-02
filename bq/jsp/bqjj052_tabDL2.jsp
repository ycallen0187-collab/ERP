<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.bq.core.bqjc052" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>

<%! public static final String _AppId = "BQJJ052"; %>
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>

<%
    bqjc052 bq052 = new bqjc052(_dsCom);
    Map dataFac= bq052.getDashboardDataByFac(_dsCom,"D");

    List craData = (List) (dataFac != null ? dataFac.get("craFac") : new ArrayList());
    List machineData = (List) (dataFac != null ? dataFac.get("machineFac") : new ArrayList());
    List fklData = (List) (dataFac != null ? dataFac.get("fklFac") : new ArrayList());
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
<meta charset="cp950">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
body {
    margin:0;
    background:#F4F6F8;
    font-family:-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto;
}

.card {
    background:#ffffff;
    border-radius:2rem;
    padding:20px;
    margin:15px;
    border:1px solid #e5e7eb;
    box-shadow:0 4px 12px rgba(0,0,0,0.05);
}

.toggle-btn {
    display:flex;
    justify-content:space-between;
    align-items:center;
    background:none;
    border:none;
    width:100%;
    cursor:pointer;
    padding:0;
}

.card h3 {
    margin:0;
    font-size:16px;
    font-weight:bold;
    color:#374151;
}

.toggle-icon {
	color : #3B82F6;
    transition: transform 0.3s;
}

.toggle-btn.open .toggle-icon {
	
    transform: rotate(180deg);
}

.sub {
    font-size:13px;
    color:#9ca3af;
    margin:10px 0;
}

.list { font-size:14px; }

.item {
    display:flex;
    justify-content:space-between;
    padding:6px 0;
    border-bottom:1px solid #f1f5f9;
}

.item:last-child { border-bottom:none; }

.badge {
	color : black;
    font-size:12px;
    background:#f3f4f6;
    padding:2px 8px;
    border-radius:6px;
}

.collapsible {
    max-height:0;
    overflow:hidden;
    transition:max-height 0.35s ease;
}

.collapsible.open {
    max-height:300px;
    overflow-y:auto;
}
</style>
</head>

<body>

<!-- 起重機 -->
<div class="card">

    <button class="toggle-btn open" onclick="toggleCard('craBox',this)">
        <h3>起重機清單</h3>
        <span class="toggle-icon">▼</span>
    </button>

    <%
        Map totalMap = (Map)craData.get(0);
        String totalCnt = totalMap.get("CNT").toString();
    %>

    <div class="sub">
        天車總數量：
        <span style="color:#f97316;font-weight:bold;"><%=totalCnt%>台</span>
    </div>

    <div id="craBox" class="collapsible open">
        <div class="list">
        <%
            for(int i=1;i<craData.size();i++){
                Map craMap = (Map)craData.get(i);
        %>
            <div class="item">
                <span><%=craMap.get("CNTTYPE")%></span>
                <span class="badge"><%=craMap.get("CNT")%>台</span>
            </div>
        <% } %>
        </div>
    </div>
</div>

<!-- 設備 -->
<div class="card">

    <button class="toggle-btn" onclick="toggleCard('equipBox',this)">
        <h3>設備清單</h3>
        <span class="toggle-icon">▼</span>
    </button>
	
	<%
        String totalCntMachine = machineData.size()+"";
    %>
    
    <div class="sub">
        設備總數量：
        <span style="color:#3b82f6;font-weight:bold;"><%=totalCntMachine%>台</span>
    </div>

    <div id="equipBox" class="collapsible">
    <%
        for(int i=1;i<machineData.size();i++){
            Map machineMap = (Map)machineData.get(i);
    %>
        <div class="item">
            <span><%=machineMap.get("設備名稱")%></span>
            <span class="badge"><%=machineMap.get("類別")%></span>
        </div>
    <% } %>
    </div>
</div>

<!-- 堆高機 -->
<div class="card">

    <button class="toggle-btn" onclick="toggleCard('fklBox',this)">
        <h3>堆高機清單</h3>
        <span class="toggle-icon">▼</span>
    </button>

    <%
        Map totalMapFKL = (Map)fklData.get(0);
        String totalCntFKL = totalMapFKL.get("CNT").toString();
    %>

    <div class="sub">
        堆高機總數量：
        <span style="color:#f97316;font-weight:bold;"><%=totalCntFKL%>台</span>
    </div>

    <div id="fklBox" class="collapsible">
        <div class="list">
        <%
            for(int i=1;i<fklData.size();i++){
                Map fklMap = (Map)fklData.get(i);
        %>
            <div class="item">
                <span><%=fklMap.get("CNTTYPE")%></span>
                <span class="badge"><%=fklMap.get("CNT")%>台</span>
            </div>
        <% } %>
        </div>
    </div>
</div>

<script>
function toggleCard(id, btn){
    var el = document.getElementById(id);

    el.classList.toggle("open");
    btn.classList.toggle("open");
}
</script>

</body>
</html>
