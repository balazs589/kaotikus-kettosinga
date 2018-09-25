%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Berczédi Balázs -  BGGUER
% M?szaki és fizikai problémák számítógépes megoldása házi feladat
% Kaotikus kett?singa szimulációja
% 2013-12-05

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = vizsgalat(tinterval, initcond, m1, m2, l1, l2, k1, k2)
% "kettosinga" fuggvenyt hasznalva a bemeno parameterekkel megadott kezdeti ertek
% kornyezeteben kis elteresekkel indulo megoldasok osszehasonlitasara
%   (kis energiakon a rendszer majdnem linearisan viselkedik,
%    kozelitoleg csatolt rezges valosul meg, eleg nagy energiakon viszont 
%    a rendszer kaotikusan kezd viselkedni, kozel azonos kezdeti allapotbol
%    a fazister egymastol tavoli pontjaiba jutnak el a megoldasok)

global g    % nehezsegi gyorsulas erteket a "kettosinga" fuggvenyben adtuk meg

% "kettosinga" fuggvenyt csak a szamitas elvegzesere hasznaljuk:
animacio='animacio_nem';
abrazolas='abrazolas_nem';

% osszesen 7db egymastol 0.001 radian nagysagrendben eltero
% kezdetiertekkel inditott mozgast vizsgalunk, amit utana 7 kulonbozo
% szinnel jelenitunk meg a fazisterben:
szin{1}='b';
szin{2}='r';
szin{3}='g';
szin{4}='k';    % bemeno parameterek altal meghatarozott kezdeti ertek a 4.
szin{5}='y';
szin{6}='c';
szin{7}='m';

% valtozok a fazister abrazolasahoz szukseges intervallumok szamara:
FI1min=0;
FI2min=0;
FI1max=0;
FI2max=0;


% 7db egymashoz nagyon kozeli kezdetiertekkel inditott kiserlet elvegzese:
for iii=1:7
    
    % lepesenkent 0.001 radiannal modositjuk az l1 palca kezdeti szogenek erteket:
    kezdetiertekek{iii} = [(4-iii)*(0.001)+initcond(1) initcond(2) initcond(3) initcond(4) ];

    % mozgas idofejlodesenek meghatarozasa:
    [T,FI,E] = kettosinga(tinterval, kezdetiertekek{iii}, m1, m2, l1, l2, k1, k2, animacio, abrazolas);
    eredmeny{iii}=[T,FI,E];

    % helyzeti energia nulla szintjenek a stabil egyensulyi helyzetbe valo eltolasa:
    Emin=-m1*g*l1-m2*g*(l1+l2);
    E=E-Emin;       
    Emin=0;
    
    %E1=2*m2*g*l2;          %
    %E2=2*(m1+m2)*g*l1;     % amennyiben szukseges: a kituntetett energiak ertekei 

    Emax=E(1);              % kezdeti energia erteke
    
    % feliratok letrehozasa
    cim1{iii}=horzcat('m1=',num2str(m1),'kg',...
                    '    m2=',num2str(m2),'kg',...
                    '    l1=',num2str(l1),'m',...
                    '    l2=',num2str(l2),'m',...
                    '    k1=',num2str(k1),'kg/s',...
                    '    k2=',num2str(k2),'kg/s' );
                
    cim2{iii}=horzcat('\phi1_0=',num2str(kezdetiertekek{iii}(1)),'rad',...
                '    \omega1_0=',num2str(initcond(2)),'rad/s',...
                '    \phi2_0=',num2str(initcond(3)),'rad',...
                '    \omega2_0=',num2str(initcond(4)),'rad/s' );
            
    cim3{iii}=horzcat('E_0=',num2str(Emax),'J', '        t=', num2str(tinterval(1)),'...', num2str(tinterval(2)),'s');
    
    
    % fazister tartomanya amibe barmelyik korabban kiszamitott megoldas elfer:
    FI1min=min(min(FI(:,1)),FI1min);
    FI2min=min(min(FI(:,3)),FI2min);
    FI1max=max(max(FI(:,1)),FI1max);
    FI2max=max(max(FI(:,3)),FI2max);

end


% 7db megoldas abrazolasa kulon grafikonokon:
for iii=1:7

    figure(iii)
    plot(eredmeny{iii}(:,2), eredmeny{iii}(:,4),szin{iii})
    axis([FI1min FI1max FI2min FI2max]);
    legend(horzcat('\phi1_0=',num2str(kezdetiertekek{iii}(1))))
    xlabel('\phi1 [rad]')
    ylabel('\phi2 [rad]')
    title({cim1{iii}, cim2{iii},  cim3{iii}});

end

% 7db megoldas abrazolasa egyszerre egy grafikonon:
figure(8)
plot(eredmeny{1}(:,2), eredmeny{1}(:,4),szin{1},...
     eredmeny{2}(:,2), eredmeny{2}(:,4),szin{2},...
     eredmeny{3}(:,2), eredmeny{3}(:,4),szin{3},...
     eredmeny{4}(:,2), eredmeny{4}(:,4),szin{4},...
     eredmeny{5}(:,2), eredmeny{5}(:,4),szin{5},...
     eredmeny{6}(:,2), eredmeny{6}(:,4),szin{6},...
     eredmeny{7}(:,2), eredmeny{7}(:,4),szin{7},...
     ...
     eredmeny{4}(1,2), eredmeny{4}(1,4),'k.', 'MarkerSize',30)

legend(horzcat('\phi1_0=',num2str(kezdetiertekek{1}(1))),...
       horzcat('\phi1_0=',num2str(kezdetiertekek{2}(1))),...
       horzcat('\phi1_0=',num2str(kezdetiertekek{3}(1))),...
       horzcat('\phi1_0=',num2str(kezdetiertekek{4}(1))),...
       horzcat('\phi1_0=',num2str(kezdetiertekek{5}(1))),...
       horzcat('\phi1_0=',num2str(kezdetiertekek{6}(1))),...
       horzcat('\phi1_0=',num2str(kezdetiertekek{7}(1)))    )
     
xlabel('\phi1 [rad]')
ylabel('\phi2 [rad]')
title({cim1{4}, cim2{4}, cim3{4}});



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pelda: m1=3kg, m2=2kg, l1=0.8m, l2=0.6m
% 1. palca atfordulasahoz szukseges minimalis energia:
% E1=78.48J
% 2. palca atfordulasahoz szukseges minimalis energia:
% E2=23.54J

% vizsgalat([0 20], [0.1 0 1 0], 3, 2, 0.8, 0.6, 0.0, 0.0);
% E=5.6J
% vizsgalat([0 20], [0.1 0 2 0], 3, 2, 0.8, 0.6, 0.0, 0.0);
% E=16.9J
% vizsgalat([0 20], [0.1 0 2.5 0], 3, 2, 0.8, 0.6, 0.0, 0.0);
% E=21.4J
%----------------------------
% vizsgalat([0 20], [1 0 pi 0], 3, 2, 0.8, 0.6, 0.0, 0.0);
% E=41.6J
% vizsgalat([0 20], [1.5 0 pi 0], 3, 2, 0.8, 0.6, 0.0, 0.0);
% E=60.0J
%----------------------------
% vizsgalat([0 20], [2.1 0 pi 0], 3, 2, 0.8, 0.6, 0.0, 0.0);
% E=82.6J
% vizsgalat([0 20], [3.1 0 pi 0], 3, 2, 0.8, 0.6, 0.0, 0.0);
% E=102.0J




