# Raporti i studentit: UrbanBike AI

Studenti: Kleo Tafa
Data: 13.11.2026
GitHub-i im: https://github.com/kleopolis/urbanbike-ai-student
Figma: https://www.figma.com/proto/PvaJAn5zZkZkEOTB2ywDZp/UrbanBike-AI-%E2%80%93--Kleo-Tafa?node-id=2-2&p=f&t=MRteN51bEaMT8oYH-1&scaling=min-zoom&content-scaling=fixed&page-id=0%3A1

## Qëllimi

Problemi që zgjidhim: Sa qira biçikletash priten për ditën pasuese në Washington, D.C.?
Target-i y: `rentals` (kolona `cnt` e UCI Bike Sharing, totali ditor i qirave).
Predictorët X: 11 veçori. Shtatë numerike: `rentals_lag1`, `rentals_lag7`, `rentals_mean7`, `temp_c_lag7`, `rain_mm_lag7`, `wind_ms_lag7`, `trend_days`. Katër kategorike: `weekday`, `month`, `workingday`, `holiday`.
Koha kur parashikojmë dhe çfarë informacioni është i njohur: parashikojmë ditën t duke supozuar se në fund të ditës t−1 njihen qiratë e ditëve t−1 dhe t−7 dhe mesatarja e 7 ditëve të kaluara. Moti hyn vetëm me vonesë 7 ditë (t−7), kështu që asnjë veçori nuk përdor motin e ditës që parashikohet. Kalendari (dita e javës, muaji, festa, dita e punës) njihet paraprakisht.

## Pastrimi

Burimet reale dhe çelësi i bashkimit: UCI Bike Sharing `day.csv` (731 ditë, 2011–2012, 0 mungesa) dhe NASA POWER `nasa_weather.csv` (731 ditë; temperatura në °C, reshjet në mm/ditë, era në m/s). Bashkimi është sipas datës (`date` = `dteday`) me `validate="one_to_one"` dhe jep 731 rreshta.
Dallimi mes origjinaleve dhe kopjes didaktike: origjinalet te `data/raw/` nuk ndryshohen. Kodi krijon veçmas `data/teaching/dirty.csv`, ku injektohen qëllimisht 18 mungesa te `temp_c`, 12 te `rain_mm`, 6 tekste "gabim" te `temp_c` dhe 12 dublime. Mungesat dhe dublimet janë të simuluara për mësim, jo gabime të burimeve reale.
Rreshtat para/pas: kopja didaktike ka 743 rreshta, pas pastrimit 731. Pas krijimit të lag-eve (7 ditët e para humbasin vonesat) mbeten 724 rreshta për modelim.
Dublimet: 12 rreshta identikë, të hequr me `drop_duplicates()`.
Mungesat para/pas konvertimit: para konvertimit 30 qeliza bosh (18 + 12). Teksti "gabim" te `temp_c` bën që kolona të jetë tekst (`str`). Pas `to_numeric(errors="coerce")` 6 tekstet bëhen NaN dhe kolona kthehet në `float64`, pra 36 mungesa meteorologjike gjithsej. Datat konvertohen në `datetime`.
Arsyeja e imputimit vetëm me train: mediana që plotëson mungesat mësohet brenda `Pipeline` vetëm nga të dhënat train (deri më 2012-04-30). Nëse do të llogaritej mbi të gjithë serinë, informacioni nga validation dhe testi (e ardhmja) do të rrjedhë në trajnim (data leakage) dhe vlerësimi do të dilte tepër optimist. Mungesa nuk trajtohet si 0 °C, sepse kjo do të ishte një temperaturë e shpikur.

## Grafikët

Vëzhgimi 1 dhe figura përkatëse: `reports/figures/01_demand.png`. Kërkesa ditore në train rritet nga rreth 1500 qira/ditë në fillim të 2011 në 4000–5000 në verën e 2011, bie në dimër dhe rritet përsëri shumë në pranverën 2012 (deri rreth 8000). Ka edhe luhatje të forta nga dita në ditë. Mesatarja e kaluar 7-ditore e zbut zhurmën dhe ndjek mirë nivelin.
Vëzhgimi 2 dhe figura përkatëse: `reports/figures/02_workingday.png`. Në train mesatarja është rreth 3761 qira/ditë në ditët e punës dhe rreth 3570 në fundjavë/festa, pra diferencë e vogël (rreth 5%). Mesatarja nuk tregon gjithë shpërndarjen. Kjo figurë nuk dallon qiratë "casual" nga ato të regjistruarat.
Vëzhgim shtesë: `reports/figures/03_weather.png`. Temperatura NASA e t−7 dhe qiratë e ditës t kanë korrelacion rreth 0.54 në train, pra lidhje pozitive mesatare.
Pse një lidhje e dukshme nuk provon shkakësi: temperatura dhe qiratë ndryshojnë së bashku sepse të dyja ndjekin stinën (dhe rritjen e sistemit me kohë). Një lidhje vizuale ose korrelacion nuk tregon se temperatura shkakton qiratë, pasi mund ta shpjegojnë faktorë të tretë si stina, koha e vitit ose rritja e shërbimit.

## Vlerësimi

Ndarja kohore: train 2011-01-08 – 2012-04-30 (479 ditë), validation 2012-05-01 – 2012-08-31 (123), test 2012-09-01 – 2012-12-31 (122).

| Modeli | Validation MAE | Test MAE | Test RMSE | Test R² |
|---|---:|---:|---:|---:|
| Yesterday | 775.203 | 916.402 | 1330.386 | 0.539 |
| DummyMean | 2953.866 | 2494.628 | 2790.064 | -1.027 |
| Ridge | 687.558 | 893.251 | 1252.655 | 0.591 |
| RandomForest | 1821.528 | 1671.499 | 2042.654 | -0.087 |

Modeli i zgjedhur nga validation dhe arsyeja: Ridge, sepse ka MAE-në më të ulët në validation (687.558) mes dy kandidatëve ML (RandomForest 1821.528). Zgjedhja u bë para se të interpretohej testi.
Rezultati i provës me Random Forest: është më keq në test (MAE 1671.499, R² -0.087), madje më keq se baseline-i "Yesterday" (916.402). Një shpjegim i mundshëm, që nuk e kemi testuar, është se pemët nuk ekstrapolojnë jashtë diapazonit të train, ndërsa niveli i qirave në vjeshtë 2012 (mesatarja e testit rreth 5687) është më i lartë se mediana e train (3907). Modeli më kompleks nuk është automatikisht më i mirë.
Interpretimi i gabimit në qira për ditë: me Ridge, parashikimi gabon mesatarisht rreth 893 qira në ditë, rreth 16% e mesatares së testit (5687). Mediana e gabimit absolut është rreth 658. Përmirësimi ndaj "Yesterday" është i vogël (916 → 893, rreth 23 qira). Gabimi më i madh është 2012-10-29: reale 22 qira, parashikuar rreth 5737 (gabim rreth 5715). Kjo përkon me Uraganin Sandy në Washington D.C., një ngjarje që asnjë veçori e modelit nuk e shpjegon.
Rezultati i klasifikimit, nëse u realizua: u realizua (demonstrim fakultativ). Pragu është mediana e train, 3907 qira; "e lartë" është rentals ≥ prag. Në test ka 103 ditë të larta dhe 19 normale. DummyMostFrequent ka accuracy 84.43% por balanced accuracy 50% dhe macro-F1 0.458. LogisticRegression ka accuracy 91.80%, balanced accuracy 77.98% dhe macro-F1 0.820. Matrica e testit është [[11, 8], [2, 101]]: 8 ditë normale dalin të larta dhe 2 të larta dalin normale. Accuracy vetëm nuk mjafton kur klasat janë të pabalancuara.

## Kufizimet

1. Një qytet (Washington D.C.) dhe një periudhë historike (2011–2012). Rezultatet nuk vlejnë automatikisht për qytete ose vite të tjera.
2. Moti vjen nga NASA POWER, me rrjet meteorologjik (reanalizë) dhe kohë LST, jo nga një stacion ose parashikim real në qytet. Lag7 nuk i zgjidh të gjitha kufizimet e të dhënave historike.
3. Parashikimi është njëditor dhe supozon se qiratë e ditës së djeshme janë të njohura. Nuk është shërbim i testuar për kërkesën e sotme dhe nuk parashikon ngjarje si Sandy.

## Kontributet individuale

| Studenti | Skedari/ekrani | Puna dhe vendimi | Commit/prova |
|---|---|---|---|
| [PLOTËSO] | [p.sh. 03_train.py] | [çfarë bëre dhe pse] | [commit hash ose figura] |
| | | | |
| | | | |

## Burimet

UCI: https://doi.org/10.24432/C5W894
NASA: https://power.larc.nasa.gov/docs/services/api/temporal/daily/
Provenienca lokale: data/raw/provenance.json
