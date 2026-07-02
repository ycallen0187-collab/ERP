<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="java.io.*"%>
<%@ page import="java.net.*"%>
<%@ page import="java.util.*"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper"%>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool"%>

<%-- 這邊以後要抽成java，但我的環境跑不了... --%>
<%@ include file="bqjj028_Inv.jsp" %>

<%
    String resultMsg = "";
    String date="", number="", format="", amount="", buyerId="", sellerId="";
    double execSeconds = 0;	//執行秒數
    boolean hasResult = false;

    if(ServletFileUpload.isMultipartContent(request)){
    	long startMillis = System.currentTimeMillis(); //計時開始
        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        try {
            List<FileItem> items = upload.parseRequest(request);
            for(FileItem item : items){
                if(!item.isFormField() && item.getSize() > 0){
                	//1. 取得 InputStream(拍照或是選取上傳的檔案)
                    //InputStream imgStream = item.getInputStream();
            		//支援多個檔案，改這邊
            		List files = new ArrayList();
            		//files.add("D:/發票1.jpg");
            		files.add(item);
            		
            		//需要GPT判讀的欄位
            		String[] ff = "：日期、號碼、格式、金額、買方統編、賣方統編".split("、");
            		List fields = new ArrayList();
            		for(int i = 0; i < ff.length; i++){
            			fields.add(ff[i]);
            		}
            		// 也可以自訂 prompt
            		String prompt = "請從這些檔案中辨識以下欄位：日期、號碼、格式、金額、買方統編、賣方統編，回傳標準JSON格式即可";
            		
                    // ====== 這裡呼叫你的辨識程式 ======
                    try {
                        // InvoiceInfo 是你自己定義的發票資訊物件
                        //your.package.InvoiceInfo info = bqInv.recognize(imgStream);
                        Map info = gpt(files, fields, prompt);
                        aajcYCATool aaTool = new aajcYCATool();

                        // 取得資訊
                        date = aaTool.getStr(info.get("日期"));
                        if(date.length() >=10 )
                        	date = date.substring(0, 10).replaceAll("-", "").replaceAll("/", "");
                        number = aaTool.getStr(info.get("號碼"));
                        format = aaTool.getStr(info.get("格式"));
                        amount = aaTool.getStr(info.get("金額"));
                        buyerId = aaTool.getStr(info.get("買方統編"));
                        sellerId = aaTool.getStr(info.get("賣方統編"));

                        resultMsg = "辨識成功！請確認發票資訊";
                        hasResult = true;
                    } catch(Exception ex) {
                        resultMsg = "辨識發票失敗：" + ex.getMessage();
                    }
                    break;
                }
            }
        } catch (Exception ex){
            resultMsg = "發生錯誤: " + ex.getMessage();
        } finally {
			execSeconds = (System.currentTimeMillis() - startMillis) / 1000.0;
		}
    }
%>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <title>發票拍照上傳辨識</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Tailwind CSS CDN（建議正式環境用自建檔案） -->
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-slate-50 font-sans">
    <div class="max-w-md mx-auto mt-8 md:mt-10 bg-white rounded-2xl shadow-xl p-8 md:p-10">
        <h2 class="text-center mb-8 text-2xl font-bold text-slate-800 tracking-wide">發票拍照上傳辨識</h2>
        <form method="post" enctype="multipart/form-data" class="flex flex-col gap-6">
            <input type="file"
                   name="photo"
                   accept="image/*"
                   capture="environment"
                   required
                   class="block w-full border border-slate-300 rounded-lg px-4 py-3 text-base file:mr-3 file:py-2 file:px-4 file:rounded-lg file:border-0 file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 transition-colors" />
            <div class="relative">
			  <button id="submitBtn"
			          type="submit"
			          class="mt-2 w-full bg-blue-600 text-white rounded-lg py-3 text-lg font-semibold hover:bg-blue-700 active:bg-blue-800 transition flex justify-center items-center"
			  >
			    上傳並辨識
			    <span id="loadingSpinner" class="ml-2 hidden">
			      <svg class="animate-spin h-6 w-6 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
			        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
			        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path>
			      </svg>
			    </span>
			  </button>
			</div>
        </form>
        <div class="mt-4 text-blue-600 text-center min-h-[1.5em] text-base font-medium"><%= resultMsg %></div>
        <% if (hasResult) { %>
        <table class="w-full border-collapse mt-6 text-base">
		    <tbody>
		    <tr class="border-b border-slate-200">
		        <td class="text-slate-500 font-medium py-3 px-2 w-1/3">日期</td>
		        <td class="text-slate-700 font-semibold py-3 px-2">
		            <input type="text"
		                   name="sellerId"
		                   value="<%= date %>"
		                   class="w-11/12 px-3 py-2 border border-slate-300 rounded-md bg-slate-50 text-slate-700 focus:outline-none focus:border-blue-500 transition"/>
		        </td>
		    </tr>
		    <tr class="border-b border-slate-200">
		        <td class="text-slate-500 font-medium py-3 px-2">號碼</td>
		        <td class="text-slate-700 font-semibold py-3 px-2">
		            <input type="text"
		                   name="sellerId"
		                   value="<%= number %>"
		                   class="w-11/12 px-3 py-2 border border-slate-300 rounded-md bg-slate-50 text-slate-700 focus:outline-none focus:border-blue-500 transition"/>
		        </td>
		    </tr>
		    <tr class="border-b border-slate-200">
		        <td class="text-slate-500 font-medium py-3 px-2">格式</td>
		        <td class="text-slate-700 font-semibold py-3 px-2">
		            <input type="text"
		                   name="sellerId"
		                   value="<%= format %>"
		                   class="w-11/12 px-3 py-2 border border-slate-300 rounded-md bg-slate-50 text-slate-700 focus:outline-none focus:border-blue-500 transition"/>
		        </td>
		    </tr>
		    <tr class="border-b border-slate-200">
		        <td class="text-slate-500 font-medium py-3 px-2">金額</td>
		        <td class="text-slate-700 font-semibold py-3 px-2">
		            <input type="text"
		                   name="sellerId"
		                   value="<%= amount %>"
		                   class="w-11/12 px-3 py-2 border border-slate-300 rounded-md bg-slate-50 text-slate-700 focus:outline-none focus:border-blue-500 transition"/>
		        </td>
		    </tr>
		    <tr class="border-b border-slate-200">
		        <td class="text-slate-500 font-medium py-3 px-2">買方統編</td>
		        <td class="text-slate-700 font-semibold py-3 px-2">
		            <input type="text"
		                   name="sellerId"
		                   value="<%= buyerId %>"
		                   class="w-11/12 px-3 py-2 border border-slate-300 rounded-md bg-slate-50 text-slate-700 focus:outline-none focus:border-blue-500 transition"/>
		        </td>
		    </tr>
		    <tr class="border-b border-slate-200">
		        <td class="text-slate-500 font-medium py-3 px-2">賣方統編</td>
		        <td class="text-slate-700 font-semibold py-3 px-2">
		            <input type="text"
		                   name="sellerId"
		                   value="<%= sellerId %>"
		                   class="w-11/12 px-3 py-2 border border-slate-300 rounded-md bg-slate-50 text-slate-700 focus:outline-none focus:border-blue-500 transition"/>
		        </td>
		    </tr>
		    <tr>
		        <td class="text-slate-500 font-medium py-3 px-2">執行時間(秒)</td>
		        <td class="text-slate-700 font-semibold py-3 px-2"><%= String.format("%.2f", execSeconds) %></td>
		    </tr>
		    </tbody>
		</table>
        <% } %>
    </div>
</body>
<script>
document.addEventListener('DOMContentLoaded', function () {
    const form = document.querySelector('form');
    const btn = document.getElementById('submitBtn');
    const spinner = document.getElementById('loadingSpinner');

    form.addEventListener('submit', function (e) {
        btn.disabled = true;
        btn.classList.add('opacity-60', 'cursor-not-allowed');
        spinner.classList.remove('hidden');
    });
});
</script>
</html>