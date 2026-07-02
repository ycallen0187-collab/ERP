<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.ds.dsjccom"%>
<%@ page import="com.icsc.bq.core.bqjc042" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%!
public static final String _AppId = "BQJJ042"; %>

<%
    // 1. 取得前端傳來的更新日期參數
    aajcYCATool aaTool = new aajcYCATool();
    String updateDate = aaTool.getStr(request.getParameter("updateDate"));
    
    // 2. 初始化 dsCom 連線
    dejc300 _de300 = new dejc300();
    dsjccom _dsCom = _de300.run(_AppId, this, request, response);
    if(_dsCom==null){ return ;
    }

    // 3. 準備抓取生產相關資料 (後續可由 bqjc042 擴充方法取得)
    // bqjc042 bq042 = new bqjc042(_dsCom);
    // Map prodData = bq042.getManufactureDataFromDB(_dsCom, updateDate);
    
    // 以下資料暫時以靜態呈現，後續可將數值改為動態取得
%>

<div id="ajax-target-content">

    <div class="section-label">今日產出總量 (指標1,3)</div>
    <div class="card">
      <div class="card-row-2">
        <div>
          <div class="metric-label">實際產出重量</div>
          <div class="big-num"><span class="metric-val">85.0</span><span class="metric-unit">噸</span></div>
          <div style="margin-top:6px;"><span class="pill pill-amber"><i class="dot-icon dot-amber"></i> 達成率 85%</span></div>
        </div>
        <div>
          <div class="metric-label">實際產出數量</div>
 
          <div class="big-num"><span class="metric-val">320</span><span class="metric-unit">支</span></div>
          <div style="margin-top:6px;"><span class="pill pill-green"><i class="dot-icon dot-green"></i> 達成率 91%</span></div>
        </div>
      </div>
      <div class="card-div-bg card-row-3">
        <div class="stat-cell">
          <div class="stat-label">計畫重量</div>
          <div class="stat-val gray">100噸</div>
        </div>
        <div class="stat-cell">
   
        <div class="stat-label">計畫數量</div>
          <div class="stat-val gray">350支</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">平均成材率</div>
          <div class="stat-val amber">95.3%</div>
        </div>
      </div>
    </div>

    <div class="section-label">站別產出達成率 (指標1,42)</div>
    <div class="card" style="padding:10px 0 6px;">
      <div class="bar-row">
 
        <span class="bar-name">製管站</span>
        <div class="bar-track"><div class="bar-fill" style="width:91%;background:#34c759;"></div></div>
        <span class="bar-val green">91%</span>
      </div>
      <div class="bar-row">
        <span class="bar-name">裁剪站</span>
        <div class="bar-track"><div class="bar-fill" style="width:85%;background:#ff9500;"></div></div>
        <span class="bar-val amber">85%</span>
      </div>
      <div class="bar-row">
        <span class="bar-name">彎管站</span>
      
  <div class="bar-track"><div class="bar-fill" style="width:78%;background:#ff9500;"></div></div>
        <span class="bar-val amber">78%</span>
      </div>
      <div class="bar-row">
        <span class="bar-name">加工站</span>
        <div class="bar-track"><div class="bar-fill" style="width:68%;background:#ff3b30;"></div></div>
        <span class="bar-val red">68% <i class="dot-icon dot-red"></i></span>
      </div>
    </div>

    <div class="section-label">今日工單執行 (指標43,45,52)</div>
    <div class="card">
      <div class="card-row-3">
        <div class="stat-cell">
    
       <div class="stat-label">開工達成率</div>
          <div class="stat-val amber">76%</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">完工工單數</div>
          <div class="stat-val blue">18張</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">工單準時率</div>
          <div class="stat-val amber">83%</div>
 
        </div>
      </div>
    </div>

    <div class="section-label">機台停機異常 (指標5,41,51)</div>
    <div class="card">
      <div class="card-row-3" style="border-bottom:1px solid #d1d1d6;">
        <div class="stat-cell">
          <div class="stat-label">停機機台數</div>
          <div class="stat-val red">5台</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">最長停機</div>
  
         <div class="stat-val red">180分</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">停機損失重量</div>
          <div class="stat-val red">8.2噸</div>
        </div>
      </div>
      <div class="list-row">
        <div>
          <div class="list-main">BF01 - 加工站</div>
        
   <div class="list-sub">機故停機 180 分鐘 - 斗二廠</div>
        </div>
        <span class="badge badge-red"><i class="dot-icon dot-red"></i> 超標</span>
      </div>
      <div class="list-row">
        <div>
          <div class="list-main">BS02 - 裁剪站</div>
          <div class="list-sub">停機 95 分鐘 - 斗一廠</div>
        </div>
        <span class="badge badge-amber"><i class="dot-icon dot-amber"></i> 警示</span>
      </div>
  
     <div class="list-row">
        <div>
          <div class="list-main">CF03 - 彎管站</div>
          <div class="list-sub">停機 75 分鐘 - 溪州廠</div>
        </div>
        <span class="badge badge-amber"><i class="dot-icon dot-amber"></i> 警示</span>
      </div>
    </div>

    <div class="section-label">機台稼動率 Top / Bottom (指標51,7)</div>
    <div class="card" style="padding:10px 0 6px;">
      <div style="padding:4px 14px 2px;font-size:10px;color:#8e8e93;">高稼動機台</div>
     
       <div class="bar-row">
        <span class="bar-name w48">MF01</span>
        <div class="bar-track"><div class="bar-fill" style="width:97%;background:#34c759;"></div></div>
        <span class="bar-val green">97%</span>
      </div>
      <div class="bar-row">
        <span class="bar-name w48">DF01</span>
        <div class="bar-track"><div class="bar-fill" style="width:95%;background:#34c759;"></div></div>
        <span class="bar-val green">95%</span>
      </div>
      <div class="bar-row">
        <span class="bar-name w48">CF02</span>
        <div class="bar-track"><div class="bar-fill" style="width:92%;background:#34c759;"></div></div>
        <span class="bar-val green">92%</span>
      </div>
      <div style="padding:4px 14px 2px;font-size:10px;color:#8e8e93;border-top:1px solid #f2f2f7;margin-top:2px;">低稼動機台</div>
      <div class="bar-row">
        <span class="bar-name w48">BM01</span>
        <div class="bar-track"><div class="bar-fill" style="width:67%;background:#ff3b30;"></div></div>
        <span class="bar-val red">67%</span>
      </div>
      <div class="bar-row">
        <span class="bar-name w48">BF01</span>
 
        <div class="bar-track"><div class="bar-fill" style="width:42%;background:#ff3b30;"></div></div>
        <span class="bar-val red">42%</span>
      </div>
    </div>

    <div class="section-label">關鍵瓶頸機台 (指標8,44,46)</div>
    <div class="card">
      <div class="card-row-2">
        <div>
          <div class="metric-label">瓶頸機台</div>
          <div class="big-num"><span class="metric-val lg amber">DF01</span></div>
          <div style="font-size:11px;color:#8e8e93;margin-top:4px;">裁剪站 - 溪州廠</div>
      
        </div>
        <div>
          <div class="metric-label">瓶頸達成率</div>
          <div class="big-num"><span class="metric-val lg amber">80</span><span class="metric-unit">%</span></div>
          <div style="font-size:10px;color:#ff9500;margin-top:4px;">28T 實際 / 35T 計畫</div>
        </div>
      </div>
      <div class="card-div-bg prog-section">
        <div class="prog-header">
          <span>瓶頸達成率</span><span class="val" style="color:#ff9500;">80% / 目標 92%</span>
   
      </div>
        <div class="prog-track" style="margin-bottom:6px;">
          <div class="prog-fill" style="width:80%;background:#ff9500;"></div>
        </div>
        <div class="prog-header">
          <span>瓶頸機台剩餘可排容量</span><span class="val blue">7T / 12支</span>
        </div>
      </div>
    </div>

    <div class="section-label">生產端良率 (指標6)</div>
    <div class="card" style="padding:10px 0 6px;">
      <div class="bar-row">
   
      <span class="bar-name">製管站</span>
        <div class="bar-track"><div class="bar-fill" style="width:98%;background:#34c759;"></div></div>
        <span class="bar-val green">98.2%</span>
      </div>
      <div class="bar-row">
        <span class="bar-name">裁剪站</span>
        <div class="bar-track"><div class="bar-fill" style="width:97%;background:#34c759;"></div></div>
        <span class="bar-val green">97.5%</span>
      </div>
      <div class="bar-row">
        <span class="bar-name">彎管站</span>
        
 <div class="bar-track"><div class="bar-fill" style="width:96%;background:#ff9500;"></div></div>
        <span class="bar-val amber">96.1%</span>
      </div>
      <div class="bar-row">
        <span class="bar-name">加工站</span>
        <div class="bar-track"><div class="bar-fill" style="width:93%;background:#ff3b30;"></div></div>
        <span class="bar-val red">93.0% <i class="dot-icon dot-red"></i></span>
      </div>
    </div>

    <div class="section-label">近7日完工達成率趨勢 (指標16,37)</div>
    <div class="card">
      <div class="card-body" style="padding-bottom:8px;">
        <svg viewBox="0 0 340 70" xmlns="http://www.w3.org/2000/svg" style="width:100%;height:70px;">
          <line x1="0" y1="14" x2="340" y2="14" stroke="#f2f2f7" stroke-width="1"/>
          <line x1="0" y1="35" x2="340" y2="35" stroke="#f2f2f7" stroke-width="1"/>
          <line x1="0" y1="56" x2="340" y2="56" stroke="#f2f2f7" stroke-width="1"/>
          <defs>
            <linearGradient id="lineGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#007aff" stop-opacity="0.15"/>
              <stop offset="100%" stop-color="#007aff" stop-opacity="0"/>
            </linearGradient>
          </defs>
          <polygon points="0,56 48,42 97,35 145,49 194,28 242,21 291,14 340,21 340,70 0,70" fill="url(#lineGrad)"/>
          <polyline points="0,56 48,42 97,35 145,49 194,28 242,21 291,14 340,21" fill="none" stroke="#007aff" stroke-width="2" stroke-linejoin="round" stroke-linecap="round"/>
          <circle cx="0"   cy="56" r="3" fill="#007aff"/>
          <circle cx="48"  cy="42" r="3" fill="#007aff"/>
          <circle cx="97"  cy="35" r="3" fill="#007aff"/>
          <circle cx="145" cy="49" r="3" fill="#ff9500"/>
          <circle cx="194" cy="28" r="3" fill="#007aff"/>
          <circle cx="242" cy="21" r="3" fill="#007aff"/>
          <circle cx="291" cy="14" r="3" fill="#34c759"/>
          <circle cx="340" cy="21" r="3" fill="#007aff"/>
          <text x="0"   y="68" font-size="8" fill="#8e8e93" text-anchor="middle">5/3</text>
          <text x="48"  y="68" font-size="8" fill="#8e8e93" text-anchor="middle">5/4</text>
          <text x="97"  y="68" font-size="8" fill="#8e8e93" text-anchor="middle">5/5</text>
          <text x="145" y="68" font-size="8" fill="#ff9500" text-anchor="middle">5/6</text>
          <text x="194" y="68" font-size="8" fill="#8e8e93" text-anchor="middle">5/7</text>
          <text x="242" y="68" font-size="8" fill="#8e8e93" text-anchor="middle">5/8</text>
          <text x="291" y="68" font-size="8" fill="#34c759" text-anchor="middle">5/9</text>
          <text x="340" y="68" font-size="8" fill="#007aff" text-anchor="middle">5/10</text>
          <text x="0"   y="50" font-size="8" fill="#8e8e93" text-anchor="middle">72%</text>
          <text x="97"  y="29" font-size="8" fill="#8e8e93" text-anchor="middle">82%</text>
          <text x="291" y="9"  font-size="8" fill="#34c759" text-anchor="middle">91%</text>
          <text x="340" y="16" font-size="8" fill="#007aff" text-anchor="middle">89%</text>
        </svg>
      </div>
      <div class="card-div-bg card-row-3">
        <div class="stat-cell"><div class="stat-label">本週平均達成</div><div class="stat-val blue">83%</div></div>
        <div class="stat-cell"><div class="stat-label">上週平均</div><div class="stat-val gray">78%</div></div>
        <div class="stat-cell"><div class="stat-label">趨勢</div><div class="stat-val green">↑ 改善</div></div>
      </div>
    </div>

    <div class="section-label">本月材料損耗率 (指標30,31,138)</div>
    <div class="card" style="padding:10px 0 6px;">
      <div class="bar-row">
        <span class="bar-name">裁剪站</span>
        <div class="bar-track"><div class="bar-fill" style="width:60%;background:#ff9500;"></div></div>
        <span class="bar-val amber">3.2%</span>
      </div>
      <div class="bar-row">
        <span class="bar-name">製管站</span>
        <div class="bar-track"><div class="bar-fill" style="width:40%;background:#ff9500;"></div></div>
        <span class="bar-val amber">2.1%</span>
      </div>
      <div class="bar-row">
        <span class="bar-name">加工站</span>
        <div class="bar-track"><div class="bar-fill" style="width:70%;background:#ff3b30;"></div></div>
        <span class="bar-val red">3.8% <i class="dot-icon dot-red"></i></span>
      </div>
      <div style="padding:6px 14px 0;font-size:10px;color:#8e8e93;">綜合損耗率 3.1%，目標 <=2.5%</div>
    </div>

</div>