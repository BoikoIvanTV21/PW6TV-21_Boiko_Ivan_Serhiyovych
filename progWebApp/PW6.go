package main

import (
	"fmt"
	"html/template"
	"math"
	"net/http"
	"strconv"
)

type OutputData struct {
	Kv1   float64
	Ne1   float64
	Pp1   float64
	Qp1   float64
	Sp1   float64
	Ip1   float64
	KvT   float64
	NeT   float64
	PpT   float64
	QpT   float64
	SpT   float64
	IpT   float64
	Map   map[string]string
}

func main() {
	http.HandleFunc("/", serveUI)
	http.HandleFunc("/execute", computeData)
	fmt.Println("http://localhost:9999")
	http.ListenAndServe(":9999", nil)
}

func serveUI(w http.ResponseWriter, r *http.Request) {
	t, _ := template.New("ui").Parse(gui)
	t.Execute(w, nil)
}

func computeData(w http.ResponseWriter, r *http.Request) {
	ph := readFloat(r.FormValue("ph"))
	kv := readFloat(r.FormValue("kv"))
	tg := readFloat(r.FormValue("tg"))

	sum_nPh := 4*ph + 2*14 + 4*42 + 1*36 + 1*20 + 1*40 + 2*32 + 1*20
	sum_nPhKv := 4*ph*0.15 + 2*14*0.12 + 4*42*0.15 + 1*36*0.3 + 1*20*0.5 + 1*40*kv + 2*32*0.2 + 1*20*0.65
	sum_nPhKvtg := 4*ph*0.15*1.33 + 2*14*0.12*1.0 + 4*42*0.15*1.33 + 1*36*0.3*tg + 1*20*0.5*0.75 + 1*40*kv*1.0 + 2*32*0.2*1.0 + 1*20*0.65*0.75
	sum_nPh2 := 4*ph*ph + 2*14*14 + 4*42*42 + 1*36*36 + 1*20*20 + 1*40*40 + 2*32*32 + 1*20*20

	kv1 := sum_nPhKv / sum_nPh
	ne1 := (sum_nPh * sum_nPh) / sum_nPh2
	kp1 := 1.25
	pp1 := kp1 * sum_nPhKv
	qp1 := 1.0 * sum_nPhKvtg
	sp1 := math.Sqrt(pp1*pp1 + qp1*qp1)
	ip1 := pp1 / 0.38

	sum_nPhT := sum_nPh*3 + 2*100 + 2*120
	sum_nPhKvT := sum_nPhKv*3 + 2*100*0.2 + 2*120*0.8
	sum_nPhKvtgT := sum_nPhKvtg*3 + 2*100*0.2*3.0
	sum_nPh2T := sum_nPh2*3 + 2*100*100 + 2*120*120

	kvT := sum_nPhKvT / sum_nPhT
	neT := (sum_nPhT * sum_nPhT) / sum_nPh2T
	kpT := 0.7
	ppT := kpT * sum_nPhKvT
	qpT := kpT * sum_nPhKvtgT
	spT := math.Sqrt(ppT*ppT + qpT*qpT)
	ipT := ppT / 0.38

	inputs := make(map[string]string)
	for k, v := range r.Form {
		inputs[k] = v[0]
	}

	res := OutputData{
		Kv1: kv1, Ne1: ne1, Pp1: pp1, Qp1: qp1, Sp1: sp1, Ip1: ip1,
		KvT: kvT, NeT: neT, PpT: ppT, QpT: qpT, SpT: spT, IpT: ipT,
		Map: inputs,
	}

	t, _ := template.New("ui").Parse(gui)
	t.Execute(w, res)
}

func readFloat(s string) float64 {
	f, _ := strconv.ParseFloat(s, 64)
	return f
}

const gui = `
<!DOCTYPE html>
<html lang="uk">
<head>
    <meta charset="UTF-8">
    <title>Навантаження (Варіант 6)</title>
    <style>
        body { 
            background: #121212; 
            color: #e0e0e0; 
            font-family: system-ui, -apple-system, sans-serif; 
            padding: 40px 20px; 
            margin: 0;
        }
        .container { 
            background: #1e1e1e; 
            padding: 40px; 
            max-width: 800px; 
            margin: 0 auto; 
            border-radius: 12px; 
            box-shadow: 0 8px 16px rgba(0,0,0,0.4); 
        }
        h1 { color: #ffffff; font-weight: 600; margin-top: 0; margin-bottom: 30px; text-align: center; }
        .grid-inputs { display: grid; grid-template-columns: 1fr; gap: 20px; margin-top: 20px; }
        label { display: block; margin-bottom: 8px; color: #a0a0a0; font-size: 0.9em; }
        input { 
            background: #2d2d2d; 
            border: 1px solid #444; 
            color: #ffffff; 
            padding: 12px; 
            width: 100%; 
            box-sizing: border-box; 
            border-radius: 6px; 
            font-size: 1em;
        }
        input:focus { outline: none; border-color: #0d6efd; }
        .btn-group { margin-top: 30px; display: flex; gap: 15px; }
        button { 
            padding: 14px; 
            border: none; 
            border-radius: 6px; 
            font-weight: 600; 
            cursor: pointer; 
            flex: 1; 
            font-size: 1em; 
            transition: background 0.2s;
        }
        .run { background: #0d6efd; color: #ffffff; }
        .run:hover { background: #0b5ed7; }
        .fill { background: #333; color: #ffffff; border: 1px solid #555; }
        .fill:hover { background: #444; }
        .output-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 40px; }
        .output-card { background: #252525; padding: 25px; border-radius: 8px; border-top: 4px solid #0d6efd; }
        .output-card h3 { margin-top: 0; color: #fff; }
        .output-card p { margin: 10px 0; color: #ccc; display: flex; justify-content: space-between; }
        .val { color: #ffffff; font-weight: bold; }
    </style>
    <script>
        function loadVariant() {
            document.getElementById('ph').value = "25";
            document.getElementById('kv').value = "0.26";
            document.getElementById('tg').value = "1.61";
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>Метод Впорядкованих Діаграм</h1>
        <form action="/execute" method="POST">
            <div class="grid-inputs">
                <div>
                    <label>Шліфувальний верстат: Рн, кВт</label>
                    <input type="text" id="ph" name="ph" value="{{.Map.ph}}">
                </div>
                <div>
                    <label>Полірувальний верстат: Кв</label>
                    <input type="text" id="kv" name="kv" value="{{.Map.kv}}">
                </div>
                <div>
                    <label>Циркулярна пила: tg(φ)</label>
                    <input type="text" id="tg" name="tg" value="{{.Map.tg}}">
                </div>
            </div>

            <div class="btn-group">
                <button type="button" class="fill" onclick="loadVariant()">Завантажити Варіант 6</button>
                <button type="submit" class="run">Розрахувати Навантаження</button>
            </div>
        </form>

        {{if .Pp1}}
        <div class="output-grid">
            <div class="output-card">
                <h3>Показники для ШР1</h3>
                <p><span>Груп. Кв:</span> <span class="val">{{printf "%.4f" .Kv1}}</span></p>
                <p><span>Ефект. кількість n_e:</span> <span class="val">{{printf "%.0f" .Ne1}}</span></p>
                <p><span>Активна Pp:</span> <span class="val">{{printf "%.2f" .Pp1}} кВт</span></p>
                <p><span>Реактивна Qp:</span> <span class="val">{{printf "%.2f" .Qp1}} квар</span></p>
                <p><span>Повна Sp:</span> <span class="val">{{printf "%.2f" .Sp1}} кВ*А</span></p>
                <p><span>Струм Ip:</span> <span class="val">{{printf "%.2f" .Ip1}} А</span></p>
            </div>
            <div class="output-card">
                <h3>Показники для Цеху</h3>
                <p><span>Груп. Кв:</span> <span class="val">{{printf "%.4f" .KvT}}</span></p>
                <p><span>Ефект. кількість n_e:</span> <span class="val">{{printf "%.0f" .NeT}}</span></p>
                <p><span>Активна Pp:</span> <span class="val">{{printf "%.2f" .PpT}} кВт</span></p>
                <p><span>Реактивна Qp:</span> <span class="val">{{printf "%.2f" .QpT}} квар</span></p>
                <p><span>Повна Sp:</span> <span class="val">{{printf "%.2f" .SpT}} кВ*А</span></p>
                <p><span>Струм Ip:</span> <span class="val">{{printf "%.2f" .IpT}} А</span></p>
            </div>
        </div>
        {{end}}
    </div>
</body>
</html>
`