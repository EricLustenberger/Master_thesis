% reading in net-worth percentiles 1 - 99
% per age group 26-35 (column 2), 36-45 (column 3) and 46-55 (column 4) for 2004
 
SCF_agedetail_pctiles = [...
					 
  1.    -.8756842   -.5353492   -.2256819; 
  2.    -.6655293   -.2884437   -.1155701; 
  3.    -.4913952   -.1903536   -.0338765; 
  4.    -.3541763   -.1035315    -.008427; 
  5.    -.3011797   -.0441759           0; 
  6.    -.2097116   -.0132424     .003549; 
  7.     -.145473           0     .029037; 
  8.    -.1164706           0    .0421349; 
  9.    -.0838846    .0032263    .0597112; 
 10.    -.0590183    .0161317    .0757401; 
 11.    -.0276887    .0322633      .09679; 
 12.    -.0161317    .0426337    .1256825; 
 13.            0    .0524279    .1774482; 
 14.            0    .0588215    .2256769; 
 15.            0    .0670084    .2850729; 
 16.     .0022584    .0780772    .3490891; 
 17.     .0060193    .1011238    .3855467; 
 18.     .0225843    .1297185      .43007; 
 19.      .028272    .1421602    .5168583; 
 20.     .0316181    .1680582     .577081; 
 21.     .0367283    .1910981    .6500818; 
 22.     .0424896    .2200358    .7003501; 
 23.     .0487176    .2481794    .7864599; 
 24.     .0531164    .2978153    .9003948; 
 25.     .0645266    .3466339    .9656411; 
 26.     .0678394    .3823203    1.049551; 
 27.     .0810518    .4102776    1.105933; 
 28.     .0867077    .4485388    1.205842; 
 29.     .0983638    .4936288    1.290533; 
 30.     .1096089    .5422164    1.348607; 
 31.     .1177611    .6111882    1.424307; 
 32.     .1355059    .6775297    1.528593; 
 33.      .146034    .7243509    1.655108; 
 34.     .1613166    .7719589    1.733563; 
 35.     .1766417    .7951667    1.836842; 
 36.     .1888584    .8126323    1.986522; 
 37.     .2022477    .8778791    2.070498; 
 38.      .224763    .9195046     2.14238; 
 39.     .2436379    .9471102     2.23344; 
 40.     .2500407    .9818692     2.32344; 
 41.     .2677523    1.043531    2.442085; 
 42.     .2806909    1.115244    2.494505; 
 43.     .3052606    1.174119    2.592842; 
 44.      .326371    1.244154    2.692051; 
 45.     .3581228    1.298003    2.844979; 
 46.     .3854226    1.355514    3.069831; 
 47.     .4074491    1.406103    3.219181; 
 48.     .4590039    1.469222    3.294951; 
 49.     .4788689    1.558318    3.406886; 
 50.     .5112495    1.656376    3.591391; 
 51.     .5804071     1.82986    3.698989; 
 52.     .6098751    1.935799    3.831466; 
 53.     .6319619    2.077758    3.990973; 
 54.     .6610046    2.139524    4.152525; 
 55.     .6868428    2.178409    4.377217; 
 56.       .73883    2.235022     4.60595; 
 57.     .7807723    2.311317    4.833045; 
 58.     .8314009    2.402895    4.955567; 
 59.     .9021997     2.60809    5.162275; 
 60.     .9341916    2.734898     5.32104; 
 61.      .977379     2.85853    5.535326; 
 62.     1.006616    3.057595    5.862751; 
 63.     1.032426    3.135994    6.209244; 
 64.     1.066616    3.210865    6.358763; 
 65.     1.105139    3.369591    6.678507; 
 66.     1.193743    3.590411    6.919982; 
 67.     1.296985    3.674166    7.175684; 
 68.     1.366035    3.815886    7.491542; 
 69.     1.444648    3.954224    7.697949; 
 70.     1.557689    4.085281    7.987335; 
 71.     1.641235    4.324071    8.392654; 
 72.     1.679421    4.604408    8.836779; 
 73.     1.725301    4.714768    9.207565; 
 74.      1.78771    4.833045    9.723551; 
 75.     1.916441    5.085084     10.1485; 
 76.      1.99285    5.275053    10.68211; 
 77.      2.08421    5.572906    11.31624; 
 78.     2.174644    5.795548    11.87423; 
 79.     2.365649    6.033573    12.21776; 
 80.     2.489239    6.362169    12.96985; 
 81.     2.576076    6.505633    13.45219; 
 82.     2.728611    6.775297    13.66376; 
 83.     2.807302    6.965564    14.17715; 
 84.     2.893772    7.403933    14.87857; 
 85.      3.03853    7.720295    15.51885; 
 86.     3.181084     8.12713    16.56914; 
 87.     3.356655    8.849628    17.13182; 
 88.     3.553954    9.718537    18.39674; 
 89.     3.984913    10.65698    19.29992; 
 90.     4.229721    11.18988    21.02105; 
 91.     4.845951    12.86375    22.98641; 
 92.     5.678344    13.63727    25.74656; 
 93.     6.110769    14.52355    28.47238; 
 94.     6.794183    16.98314    31.54133; 
 95.      7.37602     20.2474    38.58693; 
 96.     8.473936    23.27923    45.38774; 
 97.      9.92699    29.28811    64.95762; 
 98.     14.84375    48.25428     102.371; 
 99.     27.74645    65.40163    168.0774]; 



% Full distribtion
figure(1);
subplot(2,3,1);
plot(SCF_agedetail_pctiles(:,1),SCF_agedetail_pctiles(:,2),'LineWidth',3), xlabel('Percentile for age 26-35','fontsize',12), ylabel('Av. labor-earnings eqv.','fontsize',12);
set(gca,'XTick',10:10:100)
set(gca,'XTickLabel',{'','20','','40','','60','','80','','100'})
axis([1,100,-1,18]);
subplot(2,3,2);
plot(SCF_agedetail_pctiles(:,1),SCF_agedetail_pctiles(:,3),'LineWidth',3), xlabel('Percentile for age 36-45','fontsize',12), ylabel('Av. labor-earnings eqv.','fontsize',12);
title('Full Distribution','fontsize',14);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:100)
set(gca,'XTickLabel',{'','20','','40','','60','','80','','100'})
axis([1,100,-1,18]);
subplot(2,3,3);
plot(SCF_agedetail_pctiles(:,1),SCF_agedetail_pctiles(:,4),'LineWidth',3), xlabel('Percentile for age 46-55','fontsize',12), ylabel('Av. labor-earnings eqv.','fontsize',12);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:100)
set(gca,'XTickLabel',{'','20','','40','','60','','80','','100'})
axis([1,100,-1,18]);

subplot(2,3,4);
plot(SCF_agedetail_pctiles(1:90,1),SCF_agedetail_pctiles(1:90,2),'LineWidth',3), xlabel('Percentile for age 26-35','fontsize',12), ylabel('Av. labor-earnings eqv.','fontsize',12);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:100)
set(gca,'XTickLabel',{'','20','','40','','60','','80','','100'})
axis([1,100,-1,18]);
subplot(2,3,5);
plot(SCF_agedetail_pctiles(1:90,1),SCF_agedetail_pctiles(1:90,3),'LineWidth',3), xlabel('Percentile for age 36-45','fontsize',12), ylabel('Av. labor-earnings eqv.','fontsize',12);
title('up to 90th percentile','fontsize',14);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:100)
set(gca,'XTickLabel',{'','20','','40','','60','','80','','100'})
axis([1,100,-1,18]);
subplot(2,3,6);
plot(SCF_agedetail_pctiles(1:90,1),SCF_agedetail_pctiles(1:90,4),'LineWidth',3), xlabel('Percentile for age 46-55','fontsize',12), ylabel('Av. labor-earnings eqv.','fontsize',12);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:100)
set(gca,'XTickLabel',{'','20','','40','','60','','80','','100'})
axis([1,100,-1,18]);

% both together
figure(2)
subplot(1,3,1)
plot(SCF_agedetail_pctiles(1:90,1),SCF_agedetail_pctiles(1:90,2),'b',SCF_agedetail_pctiles(:,1),SCF_agedetail_pctiles(:,2),'b--','LineWidth',3), xlabel('Percentile','fontsize',12), ylabel('Av. labor-earnings eqv.','fontsize',12);
title('Age 26-35','fontsize',14);
legend('up to 90%ile','top 10%iles','Location','NorthWest')
set(gca,'XTick',10:10:100)
set(gca,'XTickLabel',{'','20','','40','','60','','80','','100'})
axis([1,100,-1,200]);
subplot(1,3,2);
plot(SCF_agedetail_pctiles(1:90,1),SCF_agedetail_pctiles(1:90,3),'b',SCF_agedetail_pctiles(:,1),SCF_agedetail_pctiles(:,3),'b--','LineWidth',3), xlabel('Percentile','fontsize',12), ylabel('Av. labor-earnings eqv.','fontsize',12);
title('Age 36-45','fontsize',14);
legend('up to 90%ile','top 10%iles','Location','NorthWest')
set(gca,'XTick',10:10:100)
set(gca,'XTickLabel',{'','20','','40','','60','','80','','100'})
axis([1,100,-1,200]);
subplot(1,3,3);
plot(SCF_agedetail_pctiles(1:90,1),SCF_agedetail_pctiles(1:90,4),'b',SCF_agedetail_pctiles(:,1),SCF_agedetail_pctiles(:,4),'b--','LineWidth',3), xlabel('Percentile','fontsize',12), ylabel('Av. labor-earnings eqv.','fontsize',12);
title('Age 46-55','fontsize',14);
legend('up to 90%ile','top 10%iles','Location','NorthWest')
set(gca,'XTick',10:10:100)
set(gca,'XTickLabel',{'','20','','40','','60','','80','','100'})
axis([1,100,-1,200]);