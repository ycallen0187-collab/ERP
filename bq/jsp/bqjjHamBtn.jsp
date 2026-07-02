<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="java.util.*"%>
<%@ page import="com.icsc.dpms.de.*, com.icsc.dpms.ds.*, com.icsc.dpms.du.*, com.icsc.dpms.ds.dao.*,com.icsc.dpms.ds.svc.*"%>
<%!
	public Map getDSMF(dsjccom dsCom,String appId){
	    try {
	        String dpSql = "SELECT a.INFODESC ,replace(a.LOCATION,'/erp','')||a.EXECOBJECT as URL  FROM db.TBDSMF a WHERE INFOID='"+appId+"' ";
			System.out.println("--sql:"+dpSql);
			Map tmp = new dejcQueryDAO(dsCom).getData(dpSql);
			if(tmp!=null && tmp.get("URL")!=null){
				return tmp;
			}
	    } catch (Exception ex) {
	        ex.printStackTrace();
	        return null;
	    }
	    return null;
	}

	public String[] getBtnList(dsjccom dsCom,String hambGroup){
	    try {
	        String dpSql = "SELECT * FROM db.TBDE23 WHERE TABID ='BQJJHAMBTN' AND FIELD2='"+hambGroup+"' ORDER BY FIELD4";
			System.out.println("--sql:"+dpSql);
			List<String> strList = new ArrayList();
			Map[] tmps = new dejcQueryDAO(dsCom).getDatas(dpSql);
			if(tmps!=null && tmps.length>0){
				for(int i=0;i<tmps.length;i++){
					Map tmp = tmps[i];
					String appId = tmp.get("FIELD1").toString();
					strList.add(appId);
				}
				System.out.println("--strList:"+strList.size());
				return strList.toArray(new String[0]);
			}
	    } catch (Exception ex) {
	        ex.printStackTrace();
	        return null;
	    }
	    return null;
	}

%>
<%
	dejc300 _de300 = new dejc300();
	dsjccom _dsCom = _de300.run("DSJJPORTAL", this, request, response);
	System.out.println("--_de300:"+_de300.getMessage());
	System.out.println("--null:"+(_dsCom==null));
	System.out.println("--dscom:"+_dsCom.user.ID);
%>
<meta charset="cp950">
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
<style>
  /* ── 漢堡選單專用 CSS (符合 CP950，不使用 Unicode 特殊字元) ── */
  .burger-btn {
    width: 32px;
    height: 32px;
    display: flex;
    flex-direction: column;
    justify-content: space-around;
    padding: 6px 4px;
    background: none;
    border: none;
    cursor: pointer;
    z-index: 15;
  }
  
  .burger-line {
    width: 24px;
    height: 3px;
    background-color: #1c1c1e;
    border-radius: 2px;
  }
  
  .burger-menu-panel {
    display: none;
    position: absolute;
    top: 40px;
    left: 0;
    background: #ffffff;
    border: 1px solid #c8c8cc;
    border-radius: 12px;
    box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.15);
    width: 160px;
    z-index: 20;
    overflow: hidden;
  }
  
  .burger-menu-panel.active {
    display: block;
  }
  
  .burger-item {
    display: block;
    padding: 12px 16px;
    color: #1c1c1e;
    text-decoration: none;
    font-size: 15px;
    font-weight: 700;
    border-bottom: 1px solid #f2f2f7;
  }
  
  .burger-item:last-child {
    border-bottom: none;
  }
  
  .burger-item:active {
    background-color: #f2f2f7;
  }
</style>
<button class="burger-btn" onclick="toggleBurgerMenu(event)">
  <span class="burger-line"></span>
  <span class="burger-line"></span>
  <span class="burger-line"></span>
</button>

<div id="burgerMenuPanel" class="burger-menu-panel">
<%
String hambGroup = request.getParameter("hambGroup");
String[] tabList = getBtnList(_dsCom, hambGroup);
dsjcagc dsagc = new dsjcagc();
//只有第一個tab要先active
for(String appId:tabList){
	Map dsmf = getDSMF(_dsCom,appId);
	System.out.println(appId+":"+dsagc.check(_dsCom, appId, _dsCom.user.ID));
	if(dsagc.check(_dsCom, appId, _dsCom.user.ID)){
		out.println("<a href='/erp"+dsmf.get("URL")+"?_nobanner=true' class='burger-item' target='_parent'>"+dsmf.get("INFODESC").toString().trim()+"</a>");
	}
}
%>
</div>

<script>
/* 控制漢堡選單展開與收合，並防範點擊空白處自動關閉 */
function toggleBurgerMenu(event) {
  event.stopPropagation();
  const panel = document.getElementById('burgerMenuPanel');
  panel.classList.toggle('active');
}

document.addEventListener('click', function() {
  const panel = document.getElementById('burgerMenuPanel');
  if (panel && panel.classList.contains('active')) {
    panel.classList.remove('active');
  }
});
</script>
