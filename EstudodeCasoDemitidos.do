**************************************
*Do-File para análise dos demitidos em SC para 2017

*Banco de dados: RAIS_SC_2017
import delimited \\ESGSTATAS666666\econometria\Bases_de_Dados\RAIS\SC2017\SC2017.txt, delimiter(";") 

*Vamos manter no banco apenas as variáveis importantes para a nossa análise:
keep motivodesligamento cboocupação2002 vínculoativo3112 escolaridadeapós2005 qtdhoracontr idade mêsadmissão mêsdesligamento muntrab município nacionalidade naturezajurídica indportadordefic qtddiasafastamento raçacor vlremundezembronom vlremundezembrosm vlremunmédianom vlremunmédiasm sexotrabalhador tamanhoestabelecimento tempoemprego tipoadmissão tipoestab tipodefic

*Segundo passo, arrumar o marcador decimal, trocar de virgula para ponto e arrumar a variável CBO
sort cboocupação2002
drop in 1/429

destring motivodesligamento- tipoadmissão, dpcomma replace
rename cboocupação2002 CBO2002 

******************************
**********Pronto, mãos a obra:
*Primeiro passo, filtrar os dados para ficar apenas com os demitidos e não demitidos

*Pela RAIS, a variável motivodesligamento indica se a pessoa manteve o emprego (0) ou se ela foi desligada da empresa e o respectivo motivo:

/*
10. Rescisão   de   contrato   de   trabalho   por   justa   causa   e   iniciativa   do empregador ou demissão de servidor. 
11. Rescisão  de  contrato  de  trabalho  sem  justa  causa  por  iniciativa  do empregador  ou  exoneração  de  oficio  de  servidor  de  cargo  efetivo  ou 
exoneração de cargo em comissão. 
12. Término do contrato de trabalho. 
20. Rescisão com justa causa por iniciativa do empregado (rescisão indireta). 
21. Rescisão  sem  justa  causa  por  iniciativa  do  empregado  ou  exoneração  de cargo efetivo a pedido do servidor. 
22. Posse em outro cargo inacumulável (específico para servidor público). 
30. Transferência  de  empregado  entre  estabelecimentos  da  mesma  empresa ou para outra empresa, com ônus para a cedente. 
31. Transferência  de  empregado  entre  estabelecimentos  da  mesma  empresa ou para outra empresa, sem ônus para a cedente. 
32.Readaptação (específico para servidor público). 
33. Cessão. 
34. Redistribuição (específico para servidor público). 
40. Mudança de regime trabalhista. 
50. Reforma de militar para a reserva remunerada. 
60. Falecimento. 
62. Falecimento  decorrente  de  acidente  do  trabalho típico  (que  ocorre  no exercício de atividades profissionais a serviço da empresa).  
63. Falecimento  decorrente  de  acidente  do  trabalho de  trajeto  (ocorrido  no trajeto residência–trabalho–residência). 
64. Falecimento decorrente de doença profissional. 
70. Aposentadoria por tempo de contribuição, com rescisão contratual. 
71. Aposentadoria por tempo de contribuição, sem rescisão contratual. 
72. Aposentadoria por idade, com rescisão contratual. 
73. Aposentadoria por invalidez, decorrente de acidente do trabalho. 
74. Aposentadoria por invalidez, decorrente de doença profissional. 
75. Aposentadoria compulsória. 
76. Aposentadoria  por  invalidez,  exceto  a  decorrente  de  doença  profissional ou acidente do trabalho. 
78. Aposentadoria por idade, sem rescisão contratual. 
79. Aposentadoria especial, com rescisão contratual. 
80. Aposentadoria especial, sem rescisão contratual. 
90. Desligamento por Acordo entre empregado e empregador, art. 484-A, Lei 13.467/17
*/
*Vamof ficar então com todos os valores iguais a zero, entre 10 e 21 e 90

*Vamos eliminar (dropar) as observações que tem o código entre 22 e 80.
drop if motivodesligamento >21 & motivodesligamento <81

*Vamos agora ajustar um pouco os dados:
gen salariohora=vlremunmdianom/qtdhoracontr

*Podemos então eliminar essas poucas observaçõs que podem distorcer a an⭩se
drop if idade <14
drop if salariohora==0
drop if salariohora>10000

*podemos criar uma Dummy de Genero =0 homens e =1 mulheres
gen DG=sexotrabalhador-1

*Veja que a variável motivodesligamento indica se a pessoa foi desligada do emprego ou não já excluindo os casos de morte, aposentadoras, etc...
*Podemos criar uma nova variál indicando se a pessoa foi demitida (=1) ou não demitida (=0) e analisar as carateristicas desse grupo:
gen demitidos =1
replace demitidos =0 if motivodesligamento==0

*Vamos criar uma variável que define primeiro emprego:
gen prim_emp = 0
replace prim_emp=1 if tipoadmissão==1


*Filtraremos, por fim, apenas pessoas empregadas em empresas privadas, sem estabilidade:
 keep if naturezajurídica>=2038 & naturezajurídica<=2291

**********************************************************
**************PROBIT**************************************
**********************************************************

*Podemos pensar em analisar o modelo Probit primeiro:
*Lembre-se de dizer para o stata que ele pode parar depois de 20 interações no processo de maximaverossimilhança

probit demitidos escolaridadeapós2005 idade tempoemprego DG qtddiasafastamento qtdhoracontr vlremunmédiasm tamanhoestabelecimento prim_emp, iterate(1000)


*Podemos calcular o valor estimado de Y(probabilidade) usando o comando predict _NomeDaNovaVariavel
predict yest_probit

*Para analisar os coeficientes em termos de inclinação (dy/dx) no ponto médio:
margins, dydx(*) atmeans

*Para analisar os casos corretamente previstos:
estat classification

*******************
logit demitidos escolaridadeapós2005 idade tempoemprego DG qtddiasafastamento qtdhoracontr vlremunmédiasm tamanhoestabelecimento prim_emp, iterate(10)

***********************************
