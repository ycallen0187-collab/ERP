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

	//模擬資料
	if (request.getAttribute("Blocks") == null) {
		injectTestData(request);
	}
	
	Map[] Blocks = (Map[]) request.getAttribute("Blocks");			//BLOCK，例如：A棟1F
	Map locXY = (Map) request.getAttribute("locXY");				//儲區的位置以及庫存數量
	Map ihx = (Map) request.getAttribute("ihx");					//庫存明細
%>

<!DOCTYPE html>
<html lang="zh-Hant">
<head>
	<script type="text/javascript" src="/erp/html/chart.js"></script>
	<script src="https://cdn.tailwindcss.com"></script>

	<style>
		body {
			margin: 0;
			background: #f9fafb;
		}
		.container {
			position: relative;
			width: 80%;
			background-size: 100% 100%;
			background-repeat: no-repeat;
			border: 1px solid #ccc;
		}
		.slot {
			position: absolute;
			font-size: 14px;
			font-weight: bold;
			color: black;
			display: flex;
			align-items: center;
			justify-content: center;
			cursor: pointer;
		}
		<%-- 庫存明細 --%>
		#infoBox {
			position: absolute;
			right: 0;
			top: 0;
			bottom: 0;
			overflow-y: auto;
			background: #f9fafb;
			padding: 1rem;
			font-size: 14px;
			border-left: 1px solid #ccc;
			white-space: pre-wrap;
		}
	</style>
</head>
<body class="p-4 font-sans">
	<h1 class="text-3xl font-bold mb-4">倉庫管理 Dashboard</h1>
	<div class="bg-white p-4 rounded-xl shadow-md mb-6">
		<h2 class="text-xl font-semibold mb-4">倉儲分區（點擊顯示 2D）</h2>
		<div class="grid grid-cols-5 gap-4 text-center">
			<%
				String style = "";
				for (int i = 0; i < Blocks.length; i++) {
					String block = aaTool.getStr(Blocks[i].get("BLOCK"));
					switch (i % 5) {
						case 1: style = "bg-green"; break;
						case 2: style = "bg-yellow"; break;
						case 3: style = "bg-blue"; break;
						case 4: style = "bg-red"; break;
						default: style = "bg-orange"; break;
					}
			%>
			<div onclick="renderSlots('<%=block%>')" class="<%=style%>-300 p-4 rounded-lg cursor-pointer hover:<%=style%>-400"> <%=block%> 棟</div>
			<% } %>
		</div>
	</div>
	<div class="bg-white p-4 rounded-xl shadow-md grid grid-cols-[1fr_5fr] gap-4 mb-6">
		<div>
			<h2 class="text-xl font-semibold mb-2">庫存總覽</h2>
			<canvas id="inventoryGauge"></canvas>
		</div>
		<div>
			<h2 class="text-xl font-semibold mb-4">倉儲平面圖</h2>
			<div class="relative flex">
				<%-- 2D平面圖 --%>
				<div id="warehouse2D" class="w-[70%] flex flex-col items-center">
					<div class="container" id="container"></div>
				</div>
				<%-- 庫存明細 --%>
				<div class="w-[30%] relative">
					<div id="infoBox" class="h-full w-full overflow-auto p-4 bg-gray-50 text-gray-900">
						庫存明細
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="bg-white p-4 rounded-xl shadow-md gap-4 mb-6">
		<h2 class="text-xl font-semibold mb-2">異常警示</h2>
		<ul class="list-disc ml-5 text-red-600" id="errorInfo">
			<li>原料 A 剩餘量低於警戒值（目前：120kg）</li>
			<li>成品 C 出貨延遲超過 3 天</li>
		</ul>
	</div>

<script>
<%-- Chart.js 儀表板 透過js覆蓋 --%>
let errorInfoItems = [];  //異常警示
let totalSpace = 0;  //倉儲分區的總容量
let usedSpace = 0;   //倉儲分區的已使用量
const inventoryGaugeChart = new Chart(document.getElementById('inventoryGauge'), {
	type: 'doughnut',
	data: {
		labels: ['已用容量', '剩餘容量'],
		datasets: [{
			data: [0, 100],
			backgroundColor: ['#3b82f6', '#e5e7eb']
		}]
	},
	options: {
		cutout: '30%',
		plugins: {
			legend: { display: false },
			centerText: {
				display: true,
				text: '0%',
			}
		}
	},
	plugins: [{
		id: 'centerText',
		beforeDraw(chart) {
			const { width } = chart;
			const { height } = chart;
			const ctx = chart.ctx;
			const text = chart.options.plugins.centerText.text;
			ctx.restore();
			const fontSize = (height / 114).toFixed(2);
			ctx.font = `${fontSize}em sans-serif`;
			ctx.textBaseline = "middle";

			const textX = Math.round((width - ctx.measureText(text).width) / 2);
			const textY = height / 2;

			ctx.fillText(text, textX, textY);
			ctx.save();
		}
	}]
});
</script>

<script>
const stockDetails = <%=new ObjectMapper().writeValueAsString(ihx)%>;
const slotMap = <%=new ObjectMapper().writeValueAsString(locXY)%>;

<%-- 寫死，大小有改變要改這邊 --%>
const containerSizeMap = {
	"A12F": { width: 1761, height: 529, image: "/erp/images/bq/A12F.png" },
	"A21F": { width: 1681, height: 493, image: "/erp/images/bq/A21F.png" },
	"A22F": { width: 1201, height: 529, image: "/erp/images/bq/A22F.png" },
	"A31F": { width: 1121, height: 463, image: "/erp/images/bq/A31F.png" },
	"A32F": { width: 1864, height: 657, image: "/erp/images/bq/A32F.png" },
	"A41F": { width: 961, height: 463, image: "/erp/images/bq/A41F.png" },
	"A42F": { width: 1281, height: 529, image: "/erp/images/bq/A42F.png" },
	
	
};

<%------------------ 繪製儲位內容 -----------------%>
function renderSlots(area) {
	//清空異常array、庫存容量
	errorInfoItems.length = 0;
	totalSpace = 0;
	usedSpace = 0;
	
	const container = document.getElementById('container');
	const config = containerSizeMap[area];
	container.innerHTML = '';
	container.style.backgroundImage = `url('${config.image}')`;
	container.style.aspectRatio = `${config.width} / ${config.height}`;

	let selectedCell = null;

	Object.values(slotMap).forEach(slot => {
		if (slot.BLOCK !== area) return;
		<%-- 依據儲位座標開始畫格子 --%>		
		const div = document.createElement('div');
		div.className = 'slot';
		div.style.left = `${(slot.LEFT / config.width) * 100}%`;
		div.style.top = `${(slot.TOP / config.height) * 100}%`;
		div.style.width = `${(slot.WIDTH / config.width) * 100}%`;
		div.style.height = `${(slot.HEIGHT / config.height) * 100}%`;
		<%-- 依據儲位數量顯示顏色 --%>
		div.style.backgroundColor = slot.QTY > 5 ? '#ef4444'  // 紅色（Tailwind 的 red-500） 
			: slot.QTY > 0 ? '#4c9aff'  // 藍色
			: '#e5e7eb'; // 淺灰色
		div.textContent = slot.QTY || '';
		
		<%-- 計算使用量的百分比 --%>
		const count = Number(slot.QTY) || 0;
		totalSpace += 5;    												//計算總容量(每一區可以放五個)
		usedSpace += count;  												//增加已使用量
		if(count > 5){
			errorInfoItems.push(`儲位：${slot.ID} 料架：${count} 數量大於5`);  	//數量>5 表示有未異儲,增加訊息到異常警示
		}
		
		<%-- 點擊顯示儲位庫存明細 --%> 
		div.addEventListener('click', function () {
			const infoBox = document.getElementById('infoBox');
			const key = slot.ID;
			if (selectedCell) selectedCell.classList.remove("selected");
			selectedCell = div;
			div.classList.add("selected");

			let tipText = key + "\n";
			if(stockDetails[key]){  //有庫存
				Object.keys(stockDetails[key]).forEach((locKey) => { //找料架
					const detailList = stockDetails[key][locKey];
					tipText += "料架: "+locKey+"\n";
					if (detailList && detailList.length > 0) {
						tipText += detailList.map(item => {
							const weight = parseFloat(item.WGT);
							const formatted = weight.toLocaleString(undefined, { maximumFractionDigits: 0 });
							return `ID: ${item.ID} 重量: ${formatted} kg`;
						}).join('\n\n');
					}
					tipText +="\n\n";
				});
			}else{
				tipText += "\n無資料";
			}
			infoBox.textContent = tipText;
		});
		container.appendChild(div);
	});
	// 更新圓餅圖
	const remaining = totalSpace - usedSpace;
	const usedPercent = totalSpace > 0 ? Math.round((usedSpace / totalSpace) * 100) : 0;
	inventoryGaugeChart.data.datasets[0].data = [usedSpace, remaining];
	inventoryGaugeChart.options.plugins.centerText.text = `${usedPercent}%`;
	inventoryGaugeChart.update();

	// 更新異常清單
	updateErrorInfo();
}


//更新異常警示
function updateErrorInfo() {
	const ul = document.getElementById("errorInfo");
	if (!ul) return;
	ul.innerHTML = '';
	errorInfoItems.forEach(item => {
		const li = document.createElement('li');
		li.textContent = item;
		ul.appendChild(li);
	});
}

</script>
<script>
<%-- 預設載入第一筆 --%>
<% if (Blocks.length > 0) { %>
	renderSlots('<%=Blocks[0].get("BLOCK")%>');
	//renderSlots('A42F');
<% } %>
</script>
</body>
</html>

<%! 
public static void injectTestData(javax.servlet.http.HttpServletRequest request) {
	try {
		//塞BLOCK，例如：A棟1F
		List<Map<String, String>> blocksList = new ArrayList();
		blocksList.add(new HashMap() {{ put("BLOCK", "A21F"); }});
		blocksList.add(new HashMap() {{ put("BLOCK", "A22F"); }});
		request.setAttribute("Blocks", blocksList.toArray(new Map[0]));

		//塞哪個儲區的位置以及庫存數量
		Map<String, Map<String, Object>> locXY = new HashMap();
		Map<String, Object> xy1 = new HashMap();
		xy1.put("ID", "21A11");
		xy1.put("BLOCK", "A21F");
		xy1.put("QTY", 2);
		xy1.put("LEFT", 1604.8);
		xy1.put("TOP", 2);
		xy1.put("WIDTH", 70.14);
		xy1.put("HEIGHT", 31.33);
		locXY.put("21A11", xy1);
		request.setAttribute("locXY", locXY);

		//塞庫存明細
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
		ihx.put("21A11", t1a01List);
		request.setAttribute("ihx", ihx);
	} catch (Exception ex) {
		ex.printStackTrace();
	}
}
%>