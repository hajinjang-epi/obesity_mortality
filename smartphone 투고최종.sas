/*2021.11.19 마지막 수정*/

/**/
/*유시은*/
/*2020년 11월경 시작*/
/*2021년 **월  끝*/
/*스마트폰 사용시간 및 컨텐츠 x 식습관 및 비만*/

/*변수 
OBS (ID)
exposure: [최근 30일 동안] 스마트폰 이용 여부, 시간 (사용여부, 평일, 주말), 주로 이용한 서비스 한 가지 
outcome:   [최근 7일 동안] 아침결식 일수, 과일, 탄산음료, 단맛나는 음료, 패스트푸드, 라면, 과자, 채소, 키, 몸무게
covariance: 성별, 나이, 학년, 주거형태(가족, 친척, 하숙, 자취,기숙사, 보육시설)
				    주관적 스트레스,  주관적인 가정의 경제적 상태, 일주일 평균 용돈
				    친부모 동거여부, 친부모 학력, 
ohters: 	 STRATA, CLUSTER, WEIGHT*/

/*exposure*/
int_sp /*스마트폰 사용 여부*/
int_sp_wd /*스마트폰 사용 평균 시간_주중(분)*/
int_sp_wk /*스마트폰 사용 평균 시간_주말(분)*/
int_sp_item /*스마트폰 이용 서비스*/

/*outcome*/
f_br  /*최근 7일 동안 아침식사 빈도*/ 
f_fruit  /*최근 7일 동안 과일 섭취 빈도*/ 
f_veg  /*최근 7일 동안 채소반찬 섭취빈도*/ 
f_instnd  /*최근 7일 동안 라면 섭취빈도*/ 
f_fastfood  /*최근 7일 동안 패스트푸드 섭취빈도*/ 
f_crack  /*최근 7일 도안 과자 섭취빈도*/ 
f_soda  /*최근 7일 동안 탄산음료 섭취빈도*/ 
f_swdrink  /*최근 7일 동안 단맛 나는 음료 섭취빈도*/ 
ht /*신장*/
wt /*체중*/

/*covariate*/
sex /*성별*/ 
age /*나이*/
age_m /*월령*/ 
grade /*학년*/
ctype /*도시규모*/
m_str /*평상시 스트레스 인지*/
pr_ht /*주관적건강인지*/
e_ses /*주관적 경제상태*/
e_allwn /*일주일평균용돈*/ 
e_lt_f /*동거여부(아버지)*/
e_lt_m /*동거여부(어머니)*/
e_edu_f /*아버지 학력*/
e_edu_m /*어머니 학력*/  
pa_vig /*하루 20분 이상 격렬한 신체활동일수*/
e_s_rcrd /*학업성적*/

strata /*통합후층*/
cluster /*집락*/
w; /*가중치*/
 

libname a "C:\Users\HajinJang\Downloads\제13차(2017년)_청소년건강행태조사_DB_SAS";

/*2017년 청소년건강행태조사  데이터*/

DATA a;
set a.data17;
run;

/*surveylogistic에 필요한 데이터*/
data pop17; 
set a.pop17;
run;


DATA C;
SET A;

if f_fruit=. then delete; /*2명*/
if wt=. then delete;
if ht=. then delete; /*1884명*/
if int_sp = 1 then delete; /*7257명*/


/*EXPOSURE*/
/*하루 평균 사용시간(분) =(주중사용시간*5 + 주말사용시간*2)/7
분단위 4분위수로 나누기 : qweeksp*/
weeksp = (int_sp_wd*5 + int_sp_wk*2)/7;
if weeksp >= 0 & weeksp < 60 then qweeksp = 1;
else if weeksp > = 60 & weeksp < 120 then qweeksp = 2;
else if weeksp > = 120 & weeksp < 180 then qweeksp = 3;
else if weeksp > = 180 & weeksp < 240 then qweeksp = 4;
else if weeksp > = 240 & weeksp < 300 then qweeksp = 5;
else if weeksp > = 300 then qweeksp = 6;

/*minute -> hour로 변환*/
hweeksp= weeksp/60;
hwd= int_sp_wd/60;
hwk= int_sp_wk/60;

/*주중 평균 사용시간*/
if int_sp_wd >= 0 & int_sp_wd < 60 then wd = 1;
else if int_sp_wd > = 60 & int_sp_wd < 120 then wd = 2;
else if int_sp_wd > = 120 & int_sp_wd < 180 then wd = 3;
else if int_sp_wd > = 180 & int_sp_wd < 240 then wd = 4;
else if int_sp_wd > = 240 & int_sp_wd < 300 then wd = 5;
else if int_sp_wd > = 300 then wd = 6;

/*주말 평균 사용시간*/
if int_sp_wk >= 0 & int_sp_wk < 60 then wk = 1;
else if int_sp_wk > = 60 & int_sp_wk < 120 then wk = 2;
else if int_sp_wk > = 120 & int_sp_wk < 180 then wk = 3;
else if int_sp_wk > = 180 & int_sp_wk < 240 then wk = 4;
else if int_sp_wk > = 240 & int_sp_wk < 300 then wk = 5;
else if int_sp_wk > = 300 then wk = 6;

/*스마트폰 주로 이용한 서비스 한 가지*/
if int_sp_item in (1 2) then content=1; /*education/information search*/
else if int_sp_item in (3 10) then content=2; /*messenger/email*/
else if int_sp_item in (9 12) then content=3; /*SNS/forum*/
else if int_sp_item in (4) then content=4; /*game*/
else if int_sp_item in (5 7 8) then content=5; /*videos/music*/
else if int_sp_item in (6) then content=6; /*webtoon/web-novel*/
else if int_sp_item in (11 13) then content=7; /*shopping/others */

/*smartphone problem*/
if INT_SP_TC in (3,4) or INT_SP_TF in (3,4) or INT_SP_TS in (3,4) then prca=2; /*위험군*/
else prca=1; /*정상*/

/*OUTCOME*/
/*변수들을 BINARY 변수로 변환*/
/*아침 결식= f_br, 일주일에 다섯번 이상 아침결식을 할 경우=1 */ 
if f_br in (4 5 6 7 8) then breakfast=0;
else if f_br in (1 2 3) then breakfast=1;

/*과일= f_fruit, 1주 7회 미만 섭취=1 */
if f_fruit in (5 6 7) then fruit=0;
else if f_fruit in (1 2 3 4) then fruit=1;

/*채소=f_veg, 하루 3회 미만 섭취=1*/ 
if f_veg in (7) then vegetable =0;
else if f_veg in (1 2 3 4 5 6) then vegetable =1;

/*라면섭취=f_instnd, 일주일에 3회 이상 섭취*/
if f_instnd in (1 2) then noodle=0;
else if f_instnd in(3 4 5 6 7) then noodle=1;

/*패스트푸드=f_fastfood, 일주일에 3회 이상 섭취*/
if f_fastfood in (1 2) then fastfood=0;
else if f_fastfood in(3 4 5 6 7) then fastfood=1;

/*과자=f_crack, 일주일에 3회 이상 섭취*/
if f_crack in (1 2) then chip=0;
else if f_crack in(3 4 5 6 7) then chip=1;


/*SSB, 1일 1회 이상 섭취=1*/
IF f_soda =1 THEN N_SODA =0;
ELSE IF f_soda=2 THEN n_soda=1.5;
ELSE IF f_soda=3 THEN n_soda=3.5;
ELSE IF f_soda=4 THEN n_soda=5.5;
ELSE IF f_soda=5 THEN n_soda=7;
ELSE IF f_soda=6 THEN n_soda=14;
ELSE IF f_soda=7 THEN n_soda=21;

IF f_swdrink =1 THEN n_swdrink =0;
ELSE IF f_swdrink=2 THEN n_swdrink=1.5;
ELSE IF f_swdrink=3 THEN n_swdrink=3.5;
ELSE IF f_swdrink=4 THEN n_swdrink=5.5;
ELSE IF f_swdrink=5 THEN n_swdrink=7;
ELSE IF f_swdrink=6 THEN n_swdrink=14;
ELSE IF f_swdrink=7 THEN n_swdrink=21;

r_soda=sum(n_soda, n_swdrink);

if r_soda >= 7 then soda=1; else soda=0;

/*키, 몸무게, BMI*/
k=ht/100;
bmi=round(wt/(k*k),0.000000001);


/*2017년 소아청소년 성장도표 연령별 체질량지수 참고*/
if sex=1 then do;

*age 12;
if age_m=144 then do; pct05=15.5; pct85=23.0; pct95=25.1; end;
if age_m=145 then do; pct05=15.6; pct85=23.0; pct95=25.1; end;
if age_m=146 then do; pct05=15.6; pct85=23.1; pct95=25.2; end;
if age_m=147 then do; pct05=15.7; pct85=23.1; pct95=25.2; end;
if age_m=148 then do; pct05=15.7; pct85=23.2; pct95=25.3; end;
if age_m=149 then do; pct05=15.7; pct85=23.2; pct95=25.3; end;
if age_m=150 then do; pct05=15.8; pct85=23.3; pct95=25.4; end;
if age_m=151 then do; pct05=15.8; pct85=23.3; pct95=25.4; end;
if age_m=152 then do; pct05=15.8; pct85=23.4; pct95=25.5; end;
if age_m=153 then do; pct05=15.9; pct85=23.4; pct95=25.5; end;
if age_m=154 then do; pct05=15.9; pct85=23.5; pct95=25.6; end;
if age_m=155 then do; pct05=16.0; pct85=23.5; pct95=25.6; end;

*age 13;
if age_m=156 then do; pct05=16.0; pct85=23.6; pct95=25.7; end;
if age_m=157 then do; pct05=16.1; pct85=23.6; pct95=25.7; end;
if age_m=158 then do; pct05=16.1; pct85=23.6; pct95=25.7; end;
if age_m=159 then do; pct05=16.1; pct85=23.7; pct95=25.8; end;
if age_m=160 then do; pct05=16.2; pct85=23.7; pct95=25.8; end;
if age_m=161 then do; pct05=16.2; pct85=23.7; pct95=25.8; end;
if age_m=162 then do; pct05=16.3; pct85=23.8; pct95=25.8; end;
if age_m=163 then do; pct05=16.3; pct85=23.8; pct95=25.9; end;
if age_m=164 then do; pct05=16.3; pct85=23.8; pct95=25.9; end;
if age_m=165 then do; pct05=16.4; pct85=23.9; pct95=25.9; end;
if age_m=166 then do; pct05=16.4; pct85=23.9; pct95=26.0; end;
if age_m=167 then do; pct05=16.5; pct85=23.9; pct95=26.0; end;

*age 14;
if age_m=168 then do; pct05=16.5; pct85=23.9; pct95=26.0; end;
if age_m=169 then do; pct05=16.6; pct85=24.0; pct95=26.0; end;
if age_m=170 then do; pct05=16.6; pct85=24.0; pct95=26.1; end;
if age_m=171 then do; pct05=16.7; pct85=24.0; pct95=26.1; end;
if age_m=172 then do; pct05=16.7; pct85=24.0; pct95=26.1; end;
if age_m=173 then do; pct05=16.7; pct85=24.1; pct95=26.1; end;
if age_m=174 then do; pct05=16.8; pct85=24.1; pct95=26.1; end;
if age_m=175 then do; pct05=16.8; pct85=24.1; pct95=26.1; end;
if age_m=176 then do; pct05=16.9; pct85=24.1; pct95=26.2; end;
if age_m=177 then do; pct05=16.9; pct85=24.2; pct95=26.2; end;
if age_m=178 then do; pct05=17.0; pct85=24.2; pct95=26.2; end;
if age_m=179 then do; pct05=17.0; pct85=24.2; pct95=26.2; end;

*age 15;
if age_m=180 then do; pct05=17.0; pct85=24.2; pct95=26.2; end;
if age_m=181 then do; pct05=17.1; pct85=24.3; pct95=26.2; end;
if age_m=182 then do; pct05=17.1; pct85=24.3; pct95=26.3; end;
if age_m=183 then do; pct05=17.2; pct85=24.3; pct95=26.3; end;
if age_m=184 then do; pct05=17.2; pct85=24.3; pct95=26.3; end;
if age_m=185 then do; pct05=17.2; pct85=24.4; pct95=26.3; end;
if age_m=186 then do; pct05=17.3; pct85=24.4; pct95=26.3; end;
if age_m=187 then do; pct05=17.3; pct85=24.4; pct95=26.3; end;
if age_m=188 then do; pct05=17.4; pct85=24.4; pct95=26.4; end;
if age_m=189 then do; pct05=17.4; pct85=24.5; pct95=26.4; end;
if age_m=190 then do; pct05=17.4; pct85=24.5; pct95=26.4; end;
if age_m=191 then do; pct05=17.5; pct85=24.5; pct95=26.4; end;

*age 16;
if age_m=192 then do; pct05=17.5; pct85=24.5; pct95=26.4; end;
if age_m=193 then do; pct05=17.5; pct85=24.6; pct95=26.4; end;
if age_m=194 then do; pct05=17.6; pct85=24.6; pct95=26.5; end;
if age_m=195 then do; pct05=17.6; pct85=24.6; pct95=26.5; end;
if age_m=196 then do; pct05=17.6; pct85=24.6; pct95=26.5; end;
if age_m=197 then do; pct05=17.7; pct85=24.7; pct95=26.5; end;
if age_m=198 then do; pct05=17.7; pct85=24.7; pct95=26.5; end;
if age_m=199 then do; pct05=17.7; pct85=24.7; pct95=26.6; end;
if age_m=200 then do; pct05=17.8; pct85=24.7; pct95=26.6; end;
if age_m=201 then do; pct05=17.8; pct85=24.7; pct95=26.6; end;
if age_m=202 then do; pct05=17.8; pct85=24.8; pct95=26.6; end;
if age_m=203 then do; pct05=17.9; pct85=24.8; pct95=26.6; end;

*age 17;
if age_m=204 then do; pct05=17.9; pct85=24.8; pct95=26.6; end;
if age_m=205 then do; pct05=17.9; pct85=24.8; pct95=26.7; end;
if age_m=206 then do; pct05=18.0; pct85=24.9; pct95=26.7; end;
if age_m=207 then do; pct05=18.0; pct85=24.9; pct95=26.7; end;
if age_m=208 then do; pct05=18.0; pct85=24.9; pct95=26.7; end;
if age_m=209 then do; pct05=18.1; pct85=24.9; pct95=26.7; end;
if age_m=210 then do; pct05=18.1; pct85=25.0; pct95=26.7; end;
if age_m=211 then do; pct05=18.1; pct85=25.0; pct95=26.8; end;
if age_m=212 then do; pct05=18.1; pct85=25.0; pct95=26.8; end;
if age_m=213 then do; pct05=18.2; pct85=25.0; pct95=26.8; end;
if age_m=214 then do; pct05=18.2; pct85=25.1; pct95=26.8; end;
if age_m=215 then do; pct05=18.2; pct85=25.1; pct95=26.8; end;

*18세;
if age_m=216 then do; pct05=18.3; pct85=25.1; pct95=26.9; end;
if age_m=217 then do; pct05=18.3; pct85=25.1; pct95=26.9; end;
if age_m=218 then do; pct05=18.3; pct85=25.2; pct95=26.9; end;
if age_m=219 then do; pct05=18.3; pct85=25.2; pct95=26.9; end;
if age_m=220 then do; pct05=18.4; pct85=25.2; pct95=26.9; end;
if age_m=221 then do; pct05=18.4; pct85=25.2; pct95=26.9; end;
if age_m=222 then do; pct05=18.4; pct85=25.2; pct95=27.0; end;
if age_m=223 then do; pct05=18.5; pct85=25.3; pct95=27.0; end;
if age_m=224 then do; pct05=18.5; pct85=25.3; pct95=27.0; end;
if age_m=225 then do; pct05=18.5; pct85=25.3; pct95=27.0; end;
if age_m=226 then do; pct05=18.5; pct85=25.3; pct95=27.0; end;
if age_m=227 then do; pct05=18.6; pct85=25.4; pct95=27.0; end;
end;


if sex=2 then do;
 *age 12;
if age_m=144 then do; pct05=15.3; pct85=22.1; pct95=24.1; end;
if age_m=145 then do; pct05=15.3; pct85=22.2; pct95=24.2; end;
if age_m=146 then do; pct05=15.4; pct85=22.2; pct95=24.2; end;
if age_m=147 then do; pct05=15.4; pct85=22.3; pct95=24.3; end;
if age_m=148 then do; pct05=15.5; pct85=22.3; pct95=24.4; end;
if age_m=149 then do; pct05=15.5; pct85=22.4; pct95=24.4; end;
if age_m=150 then do; pct05=15.6; pct85=22.4; pct95=24.5; end;
if age_m=151 then do; pct05=15.6; pct85=22.5; pct95=24.5; end;
if age_m=152 then do; pct05=15.7; pct85=22.5; pct95=24.6; end;
if age_m=153 then do; pct05=15.7; pct85=22.6; pct95=24.6; end;
if age_m=154 then do; pct05=15.8; pct85=22.7; pct95=24.7; end;
if age_m=155 then do; pct05=15.8; pct85=22.7; pct95=24.7; end;

*age 13;
if age_m=156 then do; pct05=15.9; pct85=22.8; pct95=24.8; end;
if age_m=157 then do; pct05=15.9; pct85=22.8; pct95=24.8; end;
if age_m=158 then do; pct05=16.0; pct85=22.8; pct95=24.8; end;
if age_m=159 then do; pct05=16.0; pct85=22.9; pct95=24.9; end;
if age_m=160 then do; pct05=16.0; pct85=22.9; pct95=24.9; end;
if age_m=161 then do; pct05=16.1; pct85=23.0; pct95=25.0; end;
if age_m=162 then do; pct05=16.1; pct85=23.0; pct95=25.0; end;
if age_m=163 then do; pct05=16.2; pct85=23.0; pct95=25.0; end;
if age_m=164 then do; pct05=16.2; pct85=23.1; pct95=25.1; end;
if age_m=165 then do; pct05=16.3; pct85=23.1; pct95=25.1; end;
if age_m=166 then do; pct05=16.3; pct85=23.2; pct95=25.1; end;
if age_m=167 then do; pct05=16.4; pct85=23.2; pct95=25.2; end;

*age 14;
if age_m=168 then do; pct05=16.4; pct85=23.3; pct95=25.2; end;
if age_m=169 then do; pct05=16.5; pct85=23.3; pct95=25.2; end;
if age_m=170 then do; pct05=16.5; pct85=23.3; pct95=25.2; end;
if age_m=171 then do; pct05=16.6; pct85=23.3; pct95=25.3; end;
if age_m=172 then do; pct05=16.6; pct85=23.4; pct95=25.3; end;
if age_m=173 then do; pct05=16.6; pct85=23.4; pct95=25.3; end;
if age_m=174 then do; pct05=16.7; pct85=23.4; pct95=25.3; end;
if age_m=175 then do; pct05=16.7; pct85=23.5; pct95=25.3; end;
if age_m=176 then do; pct05=16.8; pct85=23.5; pct95=25.4; end;
if age_m=177 then do; pct05=16.8; pct85=23.5; pct95=25.4; end;
if age_m=178 then do; pct05=16.9; pct85=23.6; pct95=25.4; end;
if age_m=179 then do; pct05=16.9; pct85=23.6; pct95=25.4; end;

*age 15;
if age_m=180 then do; pct05=16.9; pct85=23.6; pct95=25.4; end;
if age_m=181 then do; pct05=17.0; pct85=23.6; pct95=25.4; end;
if age_m=182 then do; pct05=17.0; pct85=23.6; pct95=25.5; end;
if age_m=183 then do; pct05=17.0; pct85=23.7; pct95=25.5; end;
if age_m=184 then do; pct05=17.1; pct85=23.7; pct95=25.5; end;
if age_m=185 then do; pct05=17.1; pct85=23.7; pct95=25.5; end;
if age_m=186 then do; pct05=17.1; pct85=23.7; pct95=25.5; end;
if age_m=187 then do; pct05=17.2; pct85=23.7; pct95=25.5; end;
if age_m=188 then do; pct05=17.2; pct85=23.7; pct95=25.5; end;
if age_m=189 then do; pct05=17.2; pct85=23.7; pct95=25.5; end;
if age_m=190 then do; pct05=17.3; pct85=23.8; pct95=25.5; end;
if age_m=191 then do; pct05=17.3; pct85=23.8; pct95=25.5; end;

*age 16;
if age_m=192 then do; pct05=17.3; pct85=23.8; pct95=25.5; end;
if age_m=193 then do; pct05=17.3; pct85=23.8; pct95=25.5; end;
if age_m=194 then do; pct05=17.3; pct85=23.8; pct95=25.5; end;
if age_m=195 then do; pct05=17.4; pct85=23.8; pct95=25.5; end;
if age_m=196 then do; pct05=17.4; pct85=23.8; pct95=25.5; end;
if age_m=197 then do; pct05=17.4; pct85=23.8; pct95=25.5; end;
if age_m=198 then do; pct05=17.4; pct85=23.8; pct95=25.5; end;
if age_m=199 then do; pct05=17.4; pct85=23.8; pct95=25.5; end;
if age_m=200 then do; pct05=17.4; pct85=23.8; pct95=25.5; end;
if age_m=201 then do; pct05=17.4; pct85=23.8; pct95=25.5; end;
if age_m=202 then do; pct05=17.5; pct85=23.8; pct95=25.5; end;
if age_m=203 then do; pct05=17.5; pct85=23.8; pct95=25.5; end;

*age 17;
if age_m=204 then do; pct05=17.5; pct85=23.8; pct95=25.5; end;
if age_m=205 then do; pct05=17.5; pct85=23.8; pct95=25.5; end;
if age_m=206 then do; pct05=17.5; pct85=23.8; pct95=25.5; end;
if age_m=207 then do; pct05=17.5; pct85=23.8; pct95=25.5; end;
if age_m=208 then do; pct05=17.5; pct85=23.7; pct95=25.5; end;
if age_m=209 then do; pct05=17.5; pct85=23.7; pct95=25.5; end;
if age_m=210 then do; pct05=17.5; pct85=23.7; pct95=25.5; end;
if age_m=211 then do; pct05=17.5; pct85=23.7; pct95=25.5; end;
if age_m=212 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=213 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=214 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=215 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;

*age 18;
if age_m=216 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=217 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=218 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=219 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=220 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=221 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=222 then do; pct05=17.6; pct85=23.7; pct95=25.5; end;
if age_m=223 then do; pct05=17.6; pct85=23.6; pct95=25.5; end;
if age_m=224 then do; pct05=17.6; pct85=23.6; pct95=25.4; end;
if age_m=225 then do; pct05=17.6; pct85=23.6; pct95=25.4; end;
if age_m=226 then do; pct05=17.6; pct85=23.6; pct95=25.4; end;
if age_m=227 then do; pct05=17.7; pct85=23.6; pct95=25.4; end;
end;

if bmi^=. and age^=. and ht^=. and wt^=. and pct95^=. and pct85^=. and pct05^=. then do;
if bmi>=pct95 then g_bmi=4; /*비만*/
else if pct85<=bmi<pct95 then g_bmi=3; /*과체중*/
else if pct05<=bmi<pct85 then g_bmi=2;
else if bmi<pct05 then g_bmi=1; /*저체중*/
end;

/*과체중, 비만*/
if g_bmi in (1 2) then overweight=0;
else if g_bmi in (3 4) then overweight=1;

/*비만*/
if g_bmi in (1 2 3) then obese=0;
else if g_bmi in (4) then obese=1;


/*covariates*/

/*model 1 variables */
/*성별*/
sex = sex - 1;


/*나이*/
if age^=. then n_age=age;
else if age=. then do;
if grade=1 then n_age=13;
else if grade=2 then n_age=14;
else if grade=3 then n_age=15;
else if grade=4 then n_age=16;
else if grade=5 then n_age=17;
else if grade=6 then n_age=18;
end;


/*학년을 중학생, 고등학생으로 분류*/ 
if grade in (1 2 3) then mdh=0; /*중학생*/
else if grade in (4 5 6) then mdh=1; /*고등학생*/


/*도시규모*/
/*CTYPE*/
/*군지역, 대도시, 중소도시*/
/*결측치없음*/
if ctype="대도시" then city=3;
else if ctype="중소도시" then city=2;
else city=1; /*군지역*/


/*주관적 건강인지*/
/*역코딩*/
/*PR_HT*/
/*1=매우 건강한 편이다. 2=건강한 편이다. 3=보통이다. 4=건강하지 못한 편이다. 5=매우 건강하지 못한 편이다*/
/*결측치 없음*/
/*5의 비율이 너무 적어서 4와 결합*/
/*N_PR_HT*/
if pr_ht in (4 5) then n_pr_ht =1;
else if pr_ht =3 then n_pr_ht =2;
else if pr_ht =2 then n_pr_ht =3;
else if pr_ht =1 then n_pr_ht =4;


/*주관적 경제적 상태*/
/*e_ses*/
if e_ses in (1 2) then cee_ses=1; /*상*/
else if e_ses in (3) then cee_ses=2; /*중*/
else if e_ses in (4 5) then cee_ses=3; /*하*/

if cee_ses in (3) then ce_ses=1; /*하*/
else if cee_ses in (2) then ce_ses=2; /*중*/
else if cee_ses in (1) then ce_ses=3; /*상*/


/*주관적 스트레스*/
/*m_str*/
/*스트레스 변수 1~5:  대단히 많이 느낀다 ~ 전혀 느끼지 않는다*/
if m_str in (4 5) then stress=1; /*하*/
else if m_str in (3) then stress=2; /*중*/
else if m_str in (1 2) then stress=3; /*상*/


/*친부모동거여부*/
if e_lt_f =1 & e_lt_m =1 then parents=1; /*두 친부모*/
else if e_lt_f =1 & e_lt_m ^=1 | e_lt_f ^=1 & e_lt_m =1 then parents = 2; /*한 친부모*/
else if e_lt_f ^=1 & e_lt_m ^=1 then parents = 3; /*others*/


/*부모님 학력통합*/
/*e_edu_f 아버지 학력*/
/*e_edu_m 어머니 학력*/
if e_edu_f = 9999 | e_edu_f = 4 then e_edu_f = 0;
if e_edu_m = 9999 | e_edu_m = 4 then e_edu_m = 0;
if e_edu_f >= e_edu_m then e_parents = e_edu_f;
if e_edu_f < e_edu_m then e_parents = e_edu_m;
e_parents=e_parents+1;
/*1=결측/모름 2=중졸이하 3=고졸 4=대졸이상*/


/*신체활동*/

/*총합 60분 이상*/
/*1=없음. 2=1일. 3=2일 ... 6=5일 이상*/
/*결측치 없음*/
if pa_tot = 1 then tot=0; /*주0일*/
else if pa_tot in (2 3 4 5 6 7) then tot=1; /*주1~6일*/
else if pa_tot in (8) then tot=2; /*주7일*/

/*격렬한 신체활동 20분 이상*/
if pa_vig = 1 then vig=0; /*주0일*/
else if pa_vig in (2 3) then vig=1; /*주1~2일*/
else if pa_vig in (4 5 6) then vig=2; /*주3일이상*/

/*지침: 5~17세 어린이와 청소년은 중강도 이상의 유산소 신체활동을 매일 한 시간 이상 하고, 
최소 주 3일 이상은 고강도의 신체활동을 실시*/
if tot=0 & vig=0 then pa=1; /*둘다안지킴*/
else if tot=0 & vig=1 then pa=2;
else if tot=1 & vig=0 then pa=2;
else if tot=1 & vig=1 then pa=2;
else if tot=2 | vig=2 then pa=3; /*권고 하나라도*/



/*일주일용돈*/
/*E_ALLWN*/
/*0원~15만원이상*/
/*결측치 없음*/
/*3개로 변환*/
/*0-9999원 =1, 1만~5만=2, 5만원 이상*/
IF e_allwn = 1 THEN money=1;
ELSE IF e_allwn IN (2:5) THEN money=2;
ELSE IF e_allwn IN (6:16) THEN money=3;


/*학업성적*/
/*역코딩*/
/*E_S_RCRD*/
/*1-5. 상-하*/
if E_S_RCRD in (4 5) then E_S_RCRD= 4;

/*역코딩 1-5. 하-상*/
E_S_RCRD=5-E_S_RCRD;
run;



/*분석*/

/************************************************************************************************************************/

/*Table 1. Participant characteristics according to duration  of smartphone use */
proc surveyfreq data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;

table qweeksp/row;
table qweeksp*sex/row;
table qweeksp*mdh/row;
table qweeksp*city/row;

table qweeksp*n_pr_ht/row;
table qweeksp*ce_ses/row;
table qweeksp*stress/row;
table qweeksp*pa/row;
table qweeksp*parents/row;
table qweeksp*e_parents/row;
table qweeksp*money/row;
table qweeksp*e_s_rcrd/row;

table qweeksp*qweeksp/row;
table qweeksp*obese/row;
table qweeksp*prca/row;
run;


/************************************************************************************************************************/

/*table 2. Multivariable odds ratios (ORs) and 95% confidence intervals (CIs) for the associations of smartphone usage duration with prevalence of dietary risk factors among adolescent smartphone users, stratified by obesity*/

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model breakfast(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd  f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda prca content/clodds;
domain obese;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model fruit(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br   f_fastfood f_veg f_instnd f_crack  f_swdrink f_soda prca content/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model vegetable(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br  f_instnd f_crack  f_fastfood  f_swdrink f_soda prca content/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model noodle(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br   f_fastfood f_veg  f_crack  f_swdrink f_soda prca content/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model fastfood(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit  f_veg f_instnd f_crack  f_swdrink f_soda prca content/clodds;
domain obese;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model chip(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit f_veg f_instnd  f_swdrink f_soda prca content/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model soda(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit  f_veg f_instnd f_crack f_fastfood   prca content/clodds;
domain obese;
run;




/*table 2. Multivariable odds ratios (ORs) and 95% confidence intervals (CIs) for the associations of smartphone usage duration with prevalence of dietary risk factors among adolescent smartphone users, stratified by obesity*/
/*p-trend*/
proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') prca(ref='1')/param=ref;
model breakfast(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content  f_fruit f_veg f_instnd f_fastfood f_crack f_soda f_swdrink prca;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') prca(ref='1')/param=ref;
model fruit(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br  f_veg f_instnd f_fastfood f_crack f_soda f_swdrink prca;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') prca(ref='1')/param=ref;
model vegetable(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit  f_instnd f_fastfood f_crack f_soda f_swdrink prca;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') prca(ref='1')/param=ref;
model noodle(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit f_veg  f_fastfood f_crack f_soda f_swdrink prca;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') prca(ref='1')/param=ref;
model fastfood(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit f_veg f_instnd  f_crack f_soda f_swdrink prca;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') prca(ref='1')/param=ref;
model chip(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit f_veg f_instnd f_fastfood  f_soda f_swdrink prca;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') prca(ref='1')/param=ref;
model soda(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit f_veg f_instnd f_fastfood f_crack prca;
domain obese;
run;








/*table 2. Multivariable odds ratios (ORs) and 95% confidence intervals (CIs) for the associations of smartphone usage duration with prevalence of dietary risk factors among adolescent smartphone users, stratified by obesity*/
/*p-interaction*/
proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model breakfast(event='1') = qweeksp qweeksp*obese obese  sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd  f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda prca content/clodds;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model fruit(event='1') = qweeksp qweeksp*obese obese sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_veg f_instnd f_crack  f_fastfood  f_swdrink f_soda prca content/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model vegetable(event='1') = qweeksp qweeksp*obese obese sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit  f_instnd f_crack  f_fastfood  f_swdrink f_soda prca content/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model noodle(event='1') = qweeksp qweeksp*obese obese sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit  f_veg  f_crack  f_fastfood  f_swdrink f_soda prca content/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model fastfood(event='1') = qweeksp qweeksp*obese obese sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit f_veg  f_crack  f_instnd  f_swdrink f_soda prca content/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model chip(event='1') = qweeksp qweeksp*obese obese sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit f_veg  f_fastfood  f_instnd    f_swdrink f_soda prca content/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model soda(event='1') = qweeksp qweeksp*obese obese sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit f_veg  f_crack  f_instnd  f_fastfood   prca content/clodds;
run;



/************************************************************************************************************************/


/*table 3. Associations of most frequently used smartphone content type with prevalence of dietary risk factors among adolescents, stratified by obesity*/
proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0') prca(ref='1')/param=ref;
model breakfast(event='1') = content hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd f_fruit f_veg f_instnd f_fastfood f_crack f_soda f_swdrink prca/clodds;
domain obese;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0') prca(ref='1')/param=ref;
model fruit(event='1') = content hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd f_br f_veg f_instnd f_fastfood f_crack f_soda f_swdrink prca/clodds;
domain obese;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0') prca(ref='1')/param=ref;
model vegetable(event='1') = content hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd f_br f_fruit f_instnd f_fastfood f_crack f_soda f_swdrink prca/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0') prca(ref='1')/param=ref;
model noodle(event='1') = content hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd f_br f_fruit f_veg f_fastfood f_crack f_soda f_swdrink prca/clodds;
domain obese;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0') prca(ref='1')/param=ref;
model fastfood(event='1') = content hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd f_br f_fruit f_veg f_instnd f_crack f_soda f_swdrink prca/clodds;
domain obese;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0') prca(ref='1')/param=ref;
model chip(event='1') = content hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd f_br f_fruit f_veg f_instnd f_fastfood f_soda f_swdrink prca/clodds;
domain obese;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0') prca(ref='1')/param=ref;
model soda(event='1') = content hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd f_br f_fruit f_veg f_instnd f_fastfood f_crack prca/clodds;
domain obese;
run;



/*table 3. Associations of most frequently used smartphone content type with prevalence of dietary risk factors among adolescents, stratified by obesity*/
/* interaction*/
proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model breakfast(event='1') = content content*obese obese  sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd  f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda prca hweeksp/clodds;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model fruit(event='1') = content content*obese obese sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_veg f_instnd f_crack  f_fastfood  f_swdrink f_soda prca hweeksp/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model vegetable(event='1') = content content*obese obese sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit  f_instnd f_crack  f_fastfood  f_swdrink f_soda prca hweeksp/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model noodle(event='1') = content content*obese obese sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit  f_veg  f_crack  f_fastfood  f_swdrink f_soda prca hweeksp/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model fastfood(event='1') = content content*obese obese sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit f_veg  f_crack  f_instnd  f_swdrink f_soda prca hweeksp/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model chip(event='1') = content content*obese obese sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit f_veg  f_fastfood  f_instnd    f_swdrink f_soda prca hweeksp/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
model soda(event='1') = content content*obese obese sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit f_veg  f_crack  f_instnd  f_fastfood   prca hweeksp/clodds;
run;


/*********************************************************************************************/



/*Supplementary table 1*/
proc surveymeans data=c nomcar total=pop17 median q1 q3;
strata strata;
cluster cluster;
weight w;
var weeksp;
domain sex;
run;

proc surveymeans data=c nomcar total=pop17 median q1 q3;
strata strata;
cluster cluster;
weight w;
var weeksp;
domain sex*mdh;
run;



/*********************************************************************************************/



/*Supplementary table 2 characteristics according to content type of smartphone use*/
proc surveyfreq data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;

table content/row;
table content*sex/row;
table content*mdh/row;
table content*city/row;

table content*n_pr_ht/row;
table content*ce_ses/row;
table content*stress/row;
table content*pa/row;
table content*parents/row;
table content*e_parents/row;
table content*money/row;
table content*e_s_rcrd/row;

table content*qweeksp/row;
table content*obese/row;
table content*prca/row;
run;



/*********************************************************************************************/

/*Supplementary table 3. Multivariable odds ratios (ORs) and 95% confidence intervals (CIs) for the associations of smartphone usage duration with prevalence of dietary risk factors among non-obese adolescent smartphone users, stratified by smartphone addiction*/
proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1')/param=ref;
where obese=0;
model breakfast(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd  f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda /clodds;
domain prca;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1')/param=ref;
where obese=0;
model fruit(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br   f_fastfood f_veg f_instnd f_crack  f_swdrink f_soda /clodds;
domain prca;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1')/param=ref;
where obese=0;
model vegetable(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br  f_instnd f_crack  f_fastfood  f_swdrink f_soda /clodds;
domain prca;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1')/param=ref;
where obese=0;
model noodle(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br   f_fastfood f_veg  f_crack  f_swdrink f_soda /clodds;
domain prca;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1')/param=ref;
where obese=0;
model fastfood(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit  f_veg f_instnd f_crack  f_swdrink f_soda /clodds;
domain prca;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1')/param=ref;
where obese=0;
model chip(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit f_veg f_instnd  f_swdrink f_soda /clodds;
domain prca;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
where obese=0;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1')/param=ref;
model soda(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit  f_veg f_instnd f_crack f_fastfood   /clodds;
domain prca;
run;




/*Supple table 3. Multivariable odds ratios (ORs) and 95% confidence intervals (CIs) for the associations of smartphone usage duration with prevalence of dietary risk factors among non-obese adolescent smartphone users, stratified by smartphone addiction*/
/*p-trend */
proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1')/param=ref;
where obese=0;
model breakfast(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd  f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda /clodds;
domain prca;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1')/param=ref;
where obese=0;
model fruit(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br   f_fastfood f_veg f_instnd f_crack  f_swdrink f_soda /clodds;
domain prca;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1')/param=ref;
where obese=0;
model vegetable(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br  f_instnd f_crack  f_fastfood  f_swdrink f_soda /clodds;
domain prca;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1')/param=ref;
where obese=0;
model noodle(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br   f_fastfood f_veg  f_crack  f_swdrink f_soda /clodds;
domain prca;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1')/param=ref;
where obese=0;
model fastfood(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit  f_veg f_instnd f_crack  f_swdrink f_soda /clodds;
domain prca;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1')/param=ref;
where obese=0;
model chip(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit f_veg f_instnd  f_swdrink f_soda /clodds;
domain prca;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
where obese=0;
class  sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1')/param=ref;
model soda(event='1') = qweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit  f_veg f_instnd f_crack f_fastfood   /clodds;
domain prca;
run;


/*Supple table 3. Multivariable odds ratios (ORs) and 95% confidence intervals (CIs) for the associations of smartphone usage duration with prevalence of dietary risk factors among non-obese adolescent smartphone users, stratified by smartphone addiction*/
/*interaction */
proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
where obese=0;
model breakfast(event='1') = qweeksp qweeksp*prca prca  sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd  f_fruit f_veg f_instnd f_crack f_fastfood  f_swdrink f_soda  content/clodds;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
where obese=0;
model fruit(event='1') = qweeksp qweeksp*prca prca sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_veg f_instnd f_crack  f_fastfood  f_swdrink f_soda  content/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
where obese=0;
model vegetable(event='1') = qweeksp qweeksp*prca prca sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit  f_instnd f_crack  f_fastfood  f_swdrink f_soda  content/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
where obese=0;
model noodle(event='1') = qweeksp qweeksp*prca prca sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit  f_veg  f_crack  f_fastfood  f_swdrink f_soda  content/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
where obese=0;
model fastfood(event='1') = qweeksp qweeksp*prca prca sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit f_veg  f_crack  f_instnd  f_swdrink f_soda  content/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
where obese=0;
model chip(event='1') = qweeksp qweeksp*prca prca sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit f_veg  f_fastfood  f_instnd    f_swdrink f_soda  content/clodds;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class qweeksp(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') e_s_rcrd(ref='1') prca(ref='1') content(ref='1')/param=ref;
where obese=0;
model soda(event='1') = qweeksp qweeksp*prca prca sex grade city n_pr_ht ce_ses stress pa parents e_parents  e_s_rcrd f_br f_fruit f_veg  f_crack  f_instnd  f_fastfood    content/clodds;
run;





/*********************************************************************************************/



/*Supplementary table 4. Multivariable odds ratios (ORs) and 95% confidence intervals (CIs) for the associations of weekday and weekend smartphone usage duration with prevalence of dietary risk factors among adolescents, stratified by obesity*/
/*weekday OR CI*/

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wd(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model breakfast(event='1') = wd wk sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content   f_fruit f_veg f_instnd  f_fastfood f_crack  f_swdrink f_soda /clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wd(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model fruit(event='1') = wd wk sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br  f_veg f_instnd  f_fastfood f_crack  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wd(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model vegetable(event='1') = wd wk sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit  f_instnd  f_fastfood f_crack  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wd(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model noodle(event='1') = wd wk sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit f_veg   f_fastfood f_crack  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wd(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model fastfood(event='1') = wd wk sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit f_veg f_instnd  f_crack  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wd(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model chip(event='1') = wd wk sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit f_veg f_instnd  f_fastfood  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wd(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model soda(event='1') = wd wk sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit f_veg f_instnd  f_fastfood f_crack /clodds;
domain obese;
run;




/*Supplementary table 4. Multivariable odds ratios (ORs) and 95% confidence intervals (CIs) for the associations of weekday and weekend smartphone usage duration with prevalence of dietary risk factors among adolescents, stratified by obesity*/
/*weekend ORs CL*/

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wk(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model breakfast(event='1') = wk wd  sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content  f_fruit f_veg f_instnd  f_fastfood f_crack f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wk(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model fruit(event='1') = wk wd  sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content  f_br  f_veg f_instnd  f_fastfood f_crack f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wk(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model vegetable(event='1') = wk wd  sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content  f_br f_fruit  f_instnd  f_fastfood f_crack f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wk(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model noodle(event='1') = wk wd  sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content  f_br f_fruit f_veg   f_fastfood f_crack f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wk(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model fastfood(event='1') = wk wd  sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content  f_br f_fruit f_veg f_instnd   f_crack f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class wk(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model chip(event='1') = wk wd  sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content  f_br f_fruit f_veg f_instnd  f_fastfood  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class  wk(ref='1') sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model soda(event='1') = wk wd  sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content  f_br f_fruit f_veg f_instnd  f_fastfood f_crack  /clodds;
domain obese;
run;



/*Supplementary table 4. Multivariable odds ratios (ORs) and 95% confidence intervals (CIs) for the associations of weekday and weekend smartphone usage duration with prevalence of dietary risk factors among adolescents, stratified by obesity*/
/*weekday ORs CL*/
/*p-trend*/
proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model breakfast(event='1') = wd wk sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content      f_fruit f_veg f_instnd  f_fastfood f_crack  f_swdrink f_soda  /clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model fruit(event='1') = wd wk sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content    f_br  f_veg f_instnd  f_fastfood f_crack  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model vegetable(event='1') = wd wk sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content    f_br f_fruit  f_instnd  f_fastfood f_crack  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model noodle(event='1') = wd wk sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content    f_br f_fruit f_veg   f_fastfood f_crack  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model fastfood(event='1') = wd wk sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content    f_br f_fruit f_veg f_instnd   f_crack  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model chip(event='1') = wd wk sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content    f_br f_fruit f_veg f_instnd  f_fastfood   f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model soda(event='1') = wd wk sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content    f_br f_fruit f_veg f_instnd  f_fastfood f_crack   /clodds;
domain obese;
run;



/*Supplementary table 4. Multivariable odds ratios (ORs) and 95% confidence intervals (CIs) for the associations of weekday and weekend smartphone usage duration with prevalence of dietary risk factors among adolescents, stratified by obesity*/
/*weekend ORs CL*/
/*p-trend*/
proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model breakfast(event='1') = wk wd  sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content   f_fruit  f_veg f_instnd  f_fastfood f_crack  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model fruit(event='1') = wk wd  sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br   f_veg f_instnd  f_fastfood f_crack  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model vegetable(event='1') = wk wd  sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit   f_instnd  f_fastfood f_crack  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model noodle(event='1') = wk wd  sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit  f_veg   f_fastfood f_crack  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model fastfood(event='1') = wk wd  sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit  f_veg f_instnd   f_crack  f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model chip(event='1') = wk wd  sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit  f_veg f_instnd  f_fastfood   f_swdrink f_soda/clodds;
domain obese;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class  sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model soda(event='1') = wk wd  sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br f_fruit  f_veg f_instnd  f_fastfood f_crack   /clodds;
domain obese;
run;



/*********************************************************************************************/

/*Supplementary Table 5. Associations of smartphone content type with prevalence of dietary risk factors among non-obese adolescents, stratified by smartphone addiction*/

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0') prca(ref='1')/param=ref;
where obese=0;
model breakfast(event='1') = content hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd f_fruit f_veg f_instnd f_fastfood f_crack f_soda f_swdrink /clodds;
domain prca;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0') prca(ref='1')/param=ref;
where obese=0;
model fruit(event='1') = content hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd f_br f_veg f_instnd f_fastfood f_crack f_soda f_swdrink /clodds;
domain prca;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0') prca(ref='1')/param=ref;
where obese=0;
model vegetable(event='1') = content hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd f_br f_fruit f_instnd f_fastfood f_crack f_soda f_swdrink /clodds;
domain prca;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0') prca(ref='1')/param=ref;
where obese=0;
model noodle(event='1') = content hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd f_br f_fruit f_veg f_fastfood f_crack f_soda f_swdrink /clodds;
domain prca;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0') prca(ref='1')/param=ref;
where obese=0;
model fastfood(event='1') = content hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd f_br f_fruit f_veg f_instnd f_crack f_soda f_swdrink /clodds;
domain prca;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0') prca(ref='1')/param=ref;
where obese=0;
model chip(event='1') = content hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd f_br f_fruit f_veg f_instnd f_fastfood f_soda f_swdrink /clodds;
domain prca;
run;


proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0') prca(ref='1')/param=ref;
where obese=0;
model soda(event='1') = content hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd f_br f_fruit f_veg f_instnd f_fastfood f_crack /clodds;
domain prca;
run;


/********************************************************************************************************************************************************/

/*Supplemental Table 6. Associations of smartphone usage duration with prevalence of dietary factors, stratified by sex, school, perceived household income, parent’s highest education level, and perceived stress among non-obese adolescents*/

proc surveyfreq data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
table obese/row;
table breakfast/row;
table fruit/row;
table vegetable/row;
table noodle/row;
table fastfood/row;
table chip/row;
table soda/row;
run;


/*Supplemental Table 6. Associations of smartphone usage duration with prevalence of dietary factors, stratified by sex, school, perceived household income, parent’s highest education level, and perceived stress among non-obese adolescents*/
/* stratify by sex*/
proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class  sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model breakfast(event='1') = hweeksp grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content     f_fruit f_veg f_instnd f_fastfood f_crack   f_soda f_swdrink /clodds;
domain sex;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class  sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model fruit(event='1') = hweeksp grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content  f_br  f_veg f_instnd f_fastfood f_crack   f_soda f_swdrink /clodds;
domain sex;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class  sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model vegetable(event='1') = hweeksp grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content  f_br f_fruit  f_instnd f_fastfood f_crack   f_soda f_swdrink /clodds;
domain sex;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class  sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model noodle(event='1') = hweeksp grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content  f_br f_fruit f_veg  f_fastfood f_crack   f_soda f_swdrink /clodds;
domain sex;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class  sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model fastfood(event='1') = hweeksp grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content  f_br f_fruit f_veg f_instnd  f_crack   f_soda f_swdrink /clodds;
domain sex;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class  sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model chip(event='1') = hweeksp grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content  f_br f_fruit f_veg f_instnd f_fastfood    f_soda f_swdrink /clodds;
domain sex;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class  sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
model soda(event='1') = hweeksp grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content  f_br f_fruit f_veg f_instnd f_fastfood f_crack    /clodds;
domain sex;
run;



/*Supplemental Table 6. Associations of smartphone usage duration with prevalence of dietary factors, stratified by sex, school, perceived household income, parent’s highest education level, and perceived stress among non-obese adolescents*/
/* stratify by school*/

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain mdh;
model breakfast(event='1') = hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content    f_fruit f_veg f_instnd f_fastfood f_crack   f_soda f_swdrink ;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain mdh;
model fruit(event='1') = hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br   f_veg f_instnd f_fastfood f_crack   f_soda f_swdrink;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain mdh;
model vegetable(event='1') = hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br  f_fruit  f_instnd f_fastfood f_crack   f_soda f_swdrink;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain mdh;
model noodle(event='1') = hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br  f_fruit f_veg  f_fastfood f_crack   f_soda f_swdrink;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain mdh;
model fastfood(event='1') = hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br  f_fruit f_veg f_instnd  f_crack   f_soda f_swdrink;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain mdh;
model chip(event='1') = hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content f_br  f_fruit f_veg f_instnd f_fastfood    f_soda f_swdrink;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain mdh;
model soda(event='1') = hweeksp sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content    f_br  f_fruit f_veg f_instnd f_fastfood f_crack  ;
run;


/*Supplemental Table 6. Associations of smartphone usage duration with prevalence of dietary factors, stratified by sex, school, perceived household income, parent’s highest education level, and perceived stress among non-obese adolescents*/
/* stratify by perceived household income*/

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain ce_ses;
model breakfast(event='1') = hweeksp sex grade city n_pr_ht  stress pa parents e_parents money e_s_rcrd content     f_fruit f_veg f_instnd f_fastfood f_crack  f_soda f_swdrink;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain ce_ses;
model fruit(event='1') = hweeksp sex grade city n_pr_ht  stress pa parents e_parents money e_s_rcrd content  f_br   f_veg f_instnd f_fastfood f_crack  f_soda f_swdrink;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain ce_ses;
model vegetable(event='1') = hweeksp sex grade city n_pr_ht  stress pa parents e_parents money e_s_rcrd content  f_br  f_fruit  f_instnd f_fastfood f_crack  f_soda f_swdrink;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain ce_ses;
model noodle(event='1') = hweeksp sex grade city n_pr_ht  stress pa parents e_parents money e_s_rcrd content  f_br  f_fruit f_veg  f_fastfood f_crack  f_soda f_swdrink;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain ce_ses;
model fastfood(event='1') = hweeksp sex grade city n_pr_ht  stress pa parents e_parents money e_s_rcrd content  f_br  f_fruit f_veg f_instnd  f_crack  f_soda f_swdrink;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain ce_ses;
model chip(event='1') = hweeksp sex grade city n_pr_ht  stress pa parents e_parents money e_s_rcrd content  f_br  f_fruit f_veg f_instnd f_fastfood   f_soda f_swdrink;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain ce_ses;
model soda(event='1') = hweeksp sex grade city n_pr_ht  stress pa parents e_parents money e_s_rcrd content  f_br  f_fruit f_veg f_instnd f_fastfood f_crack  ;
run;


/*Supplemental Table 6. Associations of smartphone usage duration with prevalence of dietary factors, stratified by sex, school, perceived household income, parent’s highest education level, and perceived stress among non-obese adolescents*/
/*parent's highest education level*/

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain e_parents;
model breakfast(event='1') = hweeksp sex grade ce_ses city n_pr_ht  stress pa parents  money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain e_parents;
model fruit(event='1') = hweeksp sex grade ce_ses city n_pr_ht  stress pa parents  money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain e_parents;
model vegetable(event='1') = hweeksp sex grade ce_ses city n_pr_ht  stress pa parents  money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain e_parents;
model noodle(event='1') = hweeksp sex grade ce_ses city n_pr_ht  stress pa parents  money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain e_parents;
model fastfood(event='1') = hweeksp sex grade ce_ses city n_pr_ht  stress pa parents  money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain e_parents;
model chip(event='1') = hweeksp sex grade ce_ses city n_pr_ht  stress pa parents  money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain e_parents;
model soda(event='1') = hweeksp sex grade ce_ses city n_pr_ht  stress pa parents  money e_s_rcrd content;
run;



/*Supplemental Table 6. Associations of smartphone usage duration with prevalence of dietary factors, stratified by sex, school, perceived household income, parent’s highest education level, and perceived stress among non-obese adolescents*/
/*stress*/

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain stress;
model breakfast(event='1') = hweeksp sex grade ce_ses city n_pr_ht pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain stress;
model fruit(event='1') = hweeksp sex grade ce_ses city n_pr_ht pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain stress;
model vegetable(event='1') = hweeksp sex grade ce_ses city n_pr_ht pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain stress;
model noodle(event='1') = hweeksp sex grade ce_ses city n_pr_ht pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain stress;
model fastfood(event='1') = hweeksp sex grade ce_ses city n_pr_ht pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain stress;
model chip(event='1') = hweeksp sex grade ce_ses city n_pr_ht pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='1')/ param=ref;
domain stress;
model soda(event='1') = hweeksp sex grade ce_ses city n_pr_ht pa parents e_parents money e_s_rcrd content;
run;



/*Supplemental Table 6. Associations of smartphone usage duration with prevalence of dietary factors, stratified by sex, school, perceived household income, parent’s highest education level, and perceived stress among non-obese adolescents*/
/*sex*/
/*interaction*/

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model breakfast= hweeksp hweeksp*sex sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model fruit= hweeksp hweeksp*sex sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model vegetable= hweeksp hweeksp*sex sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model noodle= hweeksp hweeksp*sex sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model fastfood= hweeksp hweeksp*sex sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model chip= hweeksp hweeksp*sex sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model soda= hweeksp hweeksp*sex sex grade city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content;
run;


/*Supplemental Table 6. Associations of smartphone usage duration with prevalence of dietary factors, stratified by sex, school, perceived household income, parent’s highest education level, and perceived stress among non-obese adolescents*/
/*school*/
/*interaction*/

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') mdh(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model breakfast= hweeksp sex grade mdh hweeksp*mdh city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') mdh(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model fruit= hweeksp  sex grade mdh hweeksp*mdh city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') mdh(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model vegetable= hweeksp grade sex mdh hweeksp*mdh city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') mdh(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model noodle= hweeksp sex grade mdh hweeksp*mdh city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') mdh(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model fastfood= hweeksp  sex grade mdh hweeksp*mdh city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') mdh(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model chip= hweeksp  sex grade mdh hweeksp*mdh city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') mdh(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model soda= hweeksp  sex grade mdh hweeksp*mdh city n_pr_ht ce_ses stress pa parents e_parents money e_s_rcrd content;
run;


/*Supplemental Table 6. Associations of smartphone usage duration with prevalence of dietary factors, stratified by sex, school, perceived household income, parent’s highest education level, and perceived stress among non-obese adolescents*/
/*household income*/
/*interaction*/
proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model breakfast= hweeksp sex grade city n_pr_ht ce_ses hweeksp*ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model fruit= hweeksp sex grade city n_pr_ht ce_ses hweeksp*ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model vegetable= hweeksp sex grade city n_pr_ht ce_ses hweeksp*ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model noodle= hweeksp sex grade city n_pr_ht ce_ses hweeksp*ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model fastfood= hweeksp sex grade city n_pr_ht ce_ses hweeksp*ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model chip= hweeksp sex grade city n_pr_ht ce_ses hweeksp*ce_ses stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model soda= hweeksp sex grade city n_pr_ht ce_ses hweeksp*ce_ses stress pa parents e_parents money e_s_rcrd content;
run;



/*Supplemental Table 6. Associations of smartphone usage duration with prevalence of dietary factors, stratified by sex, school, perceived household income, parent’s highest education level, and perceived stress among non-obese adolescents*/
/*parent's highest education level*/
/*interaction*/
proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model breakfast= hweeksp hweeksp*e_parents sex grade city n_pr_ht ce_ses  stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model fruit= hweeksp hweeksp*e_parents sex grade city n_pr_ht ce_ses  stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model vegetable= hweeksp hweeksp*e_parents sex grade city n_pr_ht ce_ses  stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model noodle= hweeksp hweeksp*e_parents sex grade city n_pr_ht ce_ses  stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model fastfood= hweeksp hweeksp*e_parents sex grade city n_pr_ht ce_ses  stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model chip= hweeksp hweeksp*e_parents sex grade city n_pr_ht ce_ses  stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model soda= hweeksp hweeksp*e_parents sex grade city n_pr_ht ce_ses  stress pa parents e_parents money e_s_rcrd content;
run;


/*Supplemental Table 6. Associations of smartphone usage duration with prevalence of dietary factors, stratified by sex, school, perceived household income, parent’s highest education level, and perceived stress among non-obese adolescents*/
/*perceived stress*/
/*interaction*/

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model breakfast= hweeksp hweeksp*stress sex grade city n_pr_ht ce_ses  stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model fruit= hweeksp hweeksp*stress sex grade city n_pr_ht ce_ses  stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model vegetable= hweeksp hweeksp*stress sex grade city n_pr_ht ce_ses  stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model noodle= hweeksp hweeksp*stress sex grade city n_pr_ht ce_ses  stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model fastfood= hweeksp hweeksp*stress sex grade city n_pr_ht ce_ses  stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model chip= hweeksp hweeksp*stress sex grade city n_pr_ht ce_ses  stress pa parents e_parents money e_s_rcrd content;
run;

proc surveylogistic data=c nomcar total=pop17;
strata strata;
cluster cluster;
weight w;
class sex(ref='0') grade(ref='1') city(ref='1') n_pr_ht(ref='1') ce_ses(ref='1') stress(ref='1') pa(ref='1') parents(ref='1') e_parents(ref='1') money(ref='1') e_s_rcrd(ref='1') content(ref='1') obese(ref='0')/ param=ref;
model soda= hweeksp hweeksp*stress sex grade city n_pr_ht ce_ses  stress pa parents e_parents money e_s_rcrd content;
run;



















