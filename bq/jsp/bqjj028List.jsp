<%@ page contentType = "text/html;charset=cp950"%>


<%
String dateStr = "", timeStr = "", number = "", format = "", amount = "", buyerId = "", sellerId = "";

boolean isOk = false;
String msg = "";

try {
	System.out.println("GG" + request);
	
	dateStr = request.getParameter("dateStr");
	
	System.out.println("dateStr" + dateStr);
	
	
	timeStr = request.getParameter("timeStr");
	number = request.getParameter("number");
	format = request.getParameter("format");
	amount = request.getParameter("amount");
	buyerId = request.getParameter("buyerId");
	sellerId = request.getParameter("sellerId");

	
	
    // 這裡執行你的ERP或DB處理
    // 假設判斷都通過
    isOk = true;
    msg = "成功" + number;
    // 若有失敗，設 isOk = false, msg = "失敗:原因";
} catch(Exception ex) {
    msg = "失敗：" + number + ":" + ex.getMessage();
}

out.print(msg); // 最後直接把訊息印出，給前端fetch().then(response.text())接收
%>
