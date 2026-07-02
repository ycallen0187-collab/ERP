<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.dejcQueryDAO"%>
<%@ page import="java.util.*" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool"%>
<%! public static final String _AppId = "BQJJ026"; %>
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>
<%

	aajcYCATool aaTool = new aajcYCATool();

	//判斷是否已有資料，若沒有就塞測試資料
	if (request.getAttribute("Blocks") == null) {
		injectTestData(request);							//直接塞測試資料就可以模擬了
	}

	//組合大MAP，以便顯示--給script用	
	Map[] Blocks = (Map[]) request.getAttribute("Blocks");
	Map locXSize = (Map) request.getAttribute("locXSize");
	Map locYSize = (Map) request.getAttribute("locYSize");
	Map locZSize = (Map) request.getAttribute("locZSize");
	Map ihx = (Map) request.getAttribute("ihx");
	Map stockNum = (Map) request.getAttribute("stockNum");
%>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
	<title>倉庫管理 Dashboard + 2D 倉儲</title>
  	<script type="text/javascript" src="/erp/html/bq/chart.js"></script>
	<script src="https://cdn.tailwindcss.com"></script>
	<style>
		body {
			margin: 0;
			background: #f9fafb;
		}
		.cell {
		  	position: relative;
			width: 32px;
			height: 32px;
			margin: 2px;
			display: inline-flex;
			align-items: center;
			justify-content: center;
			border-radius: 4px;
			font-size: 12px;
			color: white;
			cursor: pointer;
		}
	</style>
</head>
<body class="p-4 font-sans">
	<h1 class="text-3xl font-bold mb-4">倉庫管理 Dashboard</h1>

	<!-- 倉儲區域切換 -->
	<div class="bg-white p-4 rounded-xl shadow-md mb-6">
		<h2 class="text-xl font-semibold mb-4">倉儲分區（點擊顯示 2D）</h2>
		<div class="grid grid-cols-5 gap-4 text-center">
		<%
			String style="";
			for (int i = 0; i < Blocks.length; i++) {
				String block = aaTool.getStr(Blocks[i].get("BLOCK"));
				switch (i % 5) {
				    case 1: style = "bg-green"; 	break;
				    case 2: style = "bg-yellow"; 	break;
				    case 3: style = "bg-blue"; 		break;
				    case 4: style = "bg-red"; 		break;
				    default: style = "bg-orange"; 	break;
				}
		%>
			<div onclick="switchBuilding('<%=block%>')" class="<%=style%>-300 p-4 rounded-lg cursor-pointer hover:<%=style%>-400"> <%=block%> 棟</div>
		<%} %>			
			
		</div>
	</div>
	
	<!-- 2D 倉儲圖區塊 -->
	<div class="bg-white p-4 rounded-xl shadow-md">
		<h2 class="text-xl font-semibold mb-4">倉儲平面圖</h2>
		<div class="relative flex">
			<!-- 左側 70% 倉儲圖（主導高度） -->
			<div id="warehouse2D" class="w-[70%] flex flex-col items-center">
				<!-- 模擬內容高度 -->
				<div class="w-full h-[600px] bg-gray-100">這是倉儲圖內容</div>
			</div>
	
			<!-- 右側 30% 包裝容器，position 相對於左側高度 -->
			<div class="w-[30%] relative">
				<!-- 固定高度、右側 scroll -->
				<div id="infoBox" class="absolute top-0 left-0 right-0 bottom-0 overflow-auto p-4 bg-gray-50 border-l border-gray-300 text-sm font-mono whitespace-pre-line text-gray-900">
				庫存明細
				</div>
			</div>
		</div>
	</div>
	
	
	<!-- Dashboard Cards -->
	<div class="grid grid-cols-3 gap-4 mb-6">
		<div class="bg-white p-4 rounded-xl shadow-md">
			<h2 class="text-xl font-semibold mb-2">庫存總覽</h2>
			<canvas id="inventoryGauge"></canvas>
		</div>
		<div class="bg-white p-4 rounded-xl shadow-md col-span-2">
			<h2 class="text-xl font-semibold mb-2">異常警示</h2>
			<ul class="list-disc ml-5 text-red-600" id="errorInfo">
				<li>原料 A 剩餘量低於警戒值（目前：120kg）</li>
				<li>成品 C 出貨延遲超過 3 天</li>
			</ul>
		</div>
	</div>
<%=new ObjectMapper().writeValueAsString(stockNum)%>
<script>
<!-- 轉換每個棟的儲區 -->
const locXSize = <%=new ObjectMapper().writeValueAsString(locXSize)%>;
const locYSize = <%=new ObjectMapper().writeValueAsString(locYSize)%>;
const stockCounts = <%=new ObjectMapper().writeValueAsString(stockNum)%>;
const stockDetails = <%=new ObjectMapper().writeValueAsString(ihx)%>;
const areas = <%=new ObjectMapper().writeValueAsString(locZSize)%>;   
let errorInfoItems = [];  //異常警示
let totalSpace = 0;  //倉儲分區的總容量
let usedSpace = 0;   //倉儲分區的已使用量
<!-- Chart.js 儀表板 -->
const pieChart = new Chart(document.getElementById('inventoryGauge'), {
	type: 'doughnut',
	data: {
		labels: ['已用容量', '剩餘容量'],
		datasets: [{
			data: [30, 70],
			backgroundColor: ['#3b82f6', '#e5e7eb']
		}]
	},
	options: {
		cutout: '30%',
		plugins: {
			legend: { display: false }
		}
	}
});
</script>

<!-- 建立單一區塊的 2D 倉儲圖（可重複呼叫） -->
<!--
  倉儲管理 Dashboard - 多區塊 Zone 呈現版
  作者：OpenAI ChatGPT
  說明：本 JSP 可將倉庫分區（如 11A、11C）依照各自的 X/Y 軸資料，分別畫出獨立 2D 倉儲圖區塊
-->
<script>
function render2D(area, container) {
	container.innerHTML = '';

	const locX = locYSize[area];
	const locY = locXSize[area];

	if (!locX || !locY) {
		container.innerHTML = `<div class='text-red-600'>?? ${area} 無 X/Y 軸資料</div>`;
		return;
	}

	const table = document.createElement("div");
	table.style.display = "inline-block";

	// 第一列：空白 + X 軸標籤
	const headerRow = document.createElement("div");
	headerRow.style.display = "flex";
	const corner = document.createElement("div");
	corner.style.width = "32px";
	corner.style.height = "32px";
	headerRow.appendChild(corner);
	locX.forEach(x => {
		const xLabel = document.createElement("div");
		xLabel.className = "cell";
		xLabel.style.backgroundColor = "#e5e7eb";
		xLabel.style.color = "#111";
		xLabel.textContent = x;
		headerRow.appendChild(xLabel);
	});
	table.appendChild(headerRow);

	// Y 軸 + 儲位格子
	locY.forEach(y => {
		const row = document.createElement("div");
		row.style.display = "flex";

		const yLabel = document.createElement("div");
		yLabel.className = "cell";
		yLabel.style.backgroundColor = "#e5e7eb";
		yLabel.style.color = "#111";
		yLabel.textContent = y;
		row.appendChild(yLabel);

		locX.forEach(x => {
			const key = area + y + x;
			//console.log("目前區域：", area + y + x);
			const count = stockCounts[key] || 0;

			const div = document.createElement("div");
			div.className = "cell text-xs text-white";
			div.style.backgroundColor = count > 0 ? '#4c9aff' : '#9ca3af';
			div.textContent = count;

			if (stockCounts[key] === undefined) {
				div.style.backgroundColor = "#e5e7eb";
				div.textContent = "";
			}else{
				totalSpace = Number(totalSpace) + 5;    //計算總容量(每一區可以放五個)
				usedSpace = Number(usedSpace) + Number(count);  //增加已使用量
				if(count > 5){
					errorInfoItems.push(`儲位：${key} 料架：${count} 數量大於5`);  //數量>5 表示有未異儲,增加訊息到異常警示
				}
			}

			//點選時顯示   BOX：D-3-SR-1592總重量51 kg(ID: P2503138001 重量: 2 kg；ID: P2503138001 重量: 49 kg)
			div.onclick = function () {
				const infoBox = document.getElementById("infoBox");
				const detailList = stockDetails[key];
				let tipHtml = `<strong>儲位：${key}</strong><br/>`;
			
				if (detailList?.length > 0) {
					let totalWgt = 0;
					const boxMap = {};
			
					// 群組資料
					detailList.forEach(item => {
						const box = item.LOC || key;
						const wgt = parseFloat(item.WGT) || 0;
						totalWgt += wgt;
			
						if (!boxMap[box]) {
							boxMap[box] = { total: 0, items: [] };
						}
						boxMap[box].total += wgt;
						boxMap[box].items.push(`ID: ${item.ID} 重量: ${wgt.toLocaleString()} kg`);
					});
			
					tipHtml += `總重量：${totalWgt.toLocaleString()} kg<br/><br/>`;
			
					for (const box in boxMap) {
						const boxInfo = boxMap[box];
						const itemStr = boxInfo.items.join('；');
						tipHtml += `<span style="color:red;font-weight:bold">BOX：${box} 總重量：${boxInfo.total.toLocaleString()} kg</span>（${itemStr}）<br/>`;
					}
				} else if (stockCounts[key] === undefined) {
					tipHtml = "";
				} else {
					tipHtml += "無資料";
				}
			
				infoBox.innerHTML = tipHtml;
			};


			row.appendChild(div);
		});

		table.appendChild(row);
	});

	container.appendChild(table);
}
//更新異常警示
function updateErrorInfo(){
	const ul = document.getElementById("errorInfo");
	ul.innerHTML = '';
	errorInfoItems.forEach(item => {
		const li = document.createElement('li');
		li.textContent = item;
		ul.appendChild(li);
	});
}
</script>

<!-- 建立整個 building 區塊，會動態塞入所有區域（如 11A、11C） -->
<script>
function switchBuilding(buildingNum) {
	//清空異常array、庫存容量
	errorInfoItems.length = 0;
	totalSpace = 0;
	usedSpace = 0;
	
	const container = document.getElementById("warehouse2D");
	container.innerHTML = '';
	container.className = "flex flex-wrap gap-6";

	const zones = areas[buildingNum];
	if (!zones || !Array.isArray(zones)) return;

	zones.forEach(zone => {
		const area = `${buildingNum}${zone}`;

		// 每個區域用一個 block 包住
		const wrapper = document.createElement("div");
		wrapper.className = "flex flex-col items-center bg-white p-3 rounded shadow border";

		const title = document.createElement("div");
		title.textContent = `區域 ${area}`;
		title.className = "font-bold mb-2 text-gray-700";
		wrapper.appendChild(title);

		const gridContainer = document.createElement("div");
		gridContainer.id = area;
		wrapper.appendChild(gridContainer);

		container.appendChild(wrapper);
		render2D(area, gridContainer);
	});
	//更新庫存分布的圓餅圖
	pieChart.data.datasets[0].data = [usedSpace,(Number(totalSpace)-Number(usedSpace))];
	pieChart.update();
	//更新異常警示
	updateErrorInfo();
}
</script>

<script>
// 預設載入第一筆
<%if(Blocks.length > 0){%>
	switchBuilding('<%=Blocks[0].get("BLOCK")%>');
<%}%>
</script>
</body>
</html>

<%! 
public static void injectTestData(javax.servlet.http.HttpServletRequest request) {
	try {
		//塞BLOCK，X、Y軸母體
		List<Map<String, String>> blocksList = new ArrayList();
		blocksList.add(new HashMap() {{ put("BLOCK", "11"); }});
		request.setAttribute("Blocks", blocksList.toArray(new Map[0]));

		//塞X軸的內容
		Map<String, List<String>> locXSize = new HashMap();
		locXSize.put("11A", Arrays.asList("1"));
		locXSize.put("11C", Arrays.asList("1"));
		request.setAttribute("locXSize", locXSize);

		//塞Y軸的內容
		Map<String, List<String>> locYSize = new HashMap();
		locYSize.put("11A", Arrays.asList("1", "2", "3", "4", "5", "6"));
		locYSize.put("11C", Arrays.asList("1", "2", "3", "4"));
		request.setAttribute("locYSize", locYSize);

		//塞Z軸的內容
		Map<String, List<String>> locZSize = new HashMap();
		locZSize.put("11", Arrays.asList("A", "C"));
		request.setAttribute("locZSize", locZSize);
		
		//塞庫存數量
		Map<String, String> stockNum = new HashMap();
		stockNum.put("11A13", "2");
		request.setAttribute("stockNum", stockNum);

		//塞庫存內容
		Map<String, List<Map<String, Object>>> ihx = new HashMap();

		List<Map<String, Object>> t1a01List = new ArrayList();
		Map<String, Object> i1 = new HashMap();
		i1.put("ID", "MAT001");
		i1.put("WGT", 1050);
		t1a01List.add(i1);
		Map<String, Object> i2 = new HashMap();
		i2.put("ID", "MAT002");
		i2.put("WGT", 980);
		t1a01List.add(i2);
		ihx.put("11A13", t1a01List);

		request.setAttribute("ihx", ihx);
	} catch (Exception ex) {
		ex.printStackTrace();
	}
}
%>