%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Berczédi Balázs -  BGGUER
% M?szaki és fizikai problémák számítógépes megoldása házi feladat
% Kaotikus kett?singa szimulációja
% 2013-12-05

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [T,FI,E] = kettosinga(tinterval, initcond, m1, m2, l1, l2, k1, k2, animacio, abrazolas)
% [T,FI,E] = kettosinga(tinterval, initcond, m1, m2, l1, l2, k1, k2, animacio, abrazolas)
%
% bemeno parameterek:
% tinterval - megoldas idointervalluma [tkezd tveg] (s)
% initcond - szogek es szogsebessegek kezdeti ertekei [fi1 omega1 fi2 omega2] (rad, rad/s)
% m1, m2 - tomegpontok tomegei (kg)
% l1, l2 - sulytalan palcak hosszai (m)
% k1, k2 - tomegpontokra hato kozegellenallasi erok egyutthatoi (kg/s)
% animacio == 'animacio_igen' eseten mozgas kozelitoleg idohelyes megjelenitese
% abrazolas == 'abrazolas_igen' eseten ido fuggvenyeben energia, szogek es
%               szogsebessegek valamint mozgas fazister vetuleteinek abrazolasa
%
% ( a programban hibakezeles nincs megvalositva,
%   helytelen ertekek megadasa eseten is elindul, es vagy megahataroz
%   egy ertelmetlen megoldast (pl. negativ kozegellenallassal)
%   vagy matlab hibauzenettel elszall a futas soran (pl negativ tomeggel)
%
% kimeno parameterek:
% T - megoldas idopontjainak oszlopvektora
% FI - idopontokhoz tartozo fi1, omega1, fi2, omega2 oszlopokbola allo matrix 
% E -idopontokhoz tartozo osszes mechanikai energia szamitott ertekei
%
% pl.:
% [T,FI,E] = kettosinga([0 40], [3.1 0 pi 0], 3, 2, 0.8, 0.6, 0.15, 0.15,'animacio_igen', 'abrazolas_igen');


global g        % nehezsegi gyorsulas erteke
g=9.81;         % m/s^2

odeset('reltol', eps, 'abstol', eps);       % difegyenlet megoldo hibajat minel kisebbre allitva

% beepitet matlab megoldoval eloallitjuk a rendszer idofejlodeset
% a lentebb megirt defferencialegyenlet-rendszert megado "dife"
% matlab alfuggveny hasznalataval:

[T,FI] = ode113(@(t,y)dife(t, y, m1, m2, l1, l2, k1, k2), tinterval, initcond);

% T -idopontok oszlopvektora
% FI = [fi1, omega1, fi2, omega2] oszlopvektorokat tartalmazo matrix

% ode113 megoldon kivul hasznalhato meg:
% ode45, ode23, ode15s, ode23s, ode23t, ode23tb



% altalanos koordinatak ismereteben minden idopillanatban meghatarozzuk
% a tomegpontok x-y koordinatait:
X1=l1*sin(FI(:,1));
Y1=-l1*cos(FI(:,1));
X2=X1+l2*sin(FI(:,3));
Y2=Y1-l2*cos(FI(:,3));

% a sebessegeket:
V1_X=FI(:,2).*l1.*cos(FI(:,1));
V1_Y=FI(:,2).*l1.*sin(FI(:,1));
V2_X=V1_X+FI(:,4).*l2.*cos(FI(:,3));
V2_Y=V1_Y+FI(:,4).*l2.*sin(FI(:,3));

% illetve a helyzeti, mozgasi es osszenergiat:
U = m1*g*Y1 + m2*g*Y2;
K = (1/2)*m1*(V1_X.^2 + V1_Y.^2) + (1/2)*m2*(V2_X.^2 + V2_Y.^2);
E=K+U;

L=1.15*(l1+l2);     % abrazolashoz szukseges meret


if strcmp(animacio,'animacio_igen')     % amennyiben a mozgas idobeli lefolyasat idohelyesen is meg akarjuk jeleniteni
    
    idofelbontas=0.04;  % egy olyan idolepteket kell megadni, amihez kepest a plottolas ideje
                        % minel jobban elhanyagolhato, de az animacio meg nem annyira szaggat

    % az osszes idopontot tartalmazo T, X1, Y1, X2, Y2 vektorokbol a
    % t, x1, y1, x2, y2, vektorokba hozzuk letre az abrazolani kivant
    % idopontok ertekeit,
    
    % kezdeti allapot kimasolasa:
    t(1)=T(1);
    x1(1)=X1(1);
    y1(1)=Y1(1);
    x2(1)=X2(1);
    y2(1)=Y2(1);
    idopont=idofelbontas;   % kihagyott idopontok intervalluma

    for iii=2:(length(T))   % a teljes megoldason vegighaladva
    
        if T(iii)>idopont   % megkeressuk a kihagyott idointervallum utani elso idopontot ami szerepel a megoldasban
                            % es az ehhez tartozo ertekeket kimasoljuk:   
            t(end+1)=T(iii);
            x1(end+1)=X1(iii);
            y1(end+1)=Y1(iii);
            x2(end+1)=X2(iii);
            y2(end+1)=Y2(iii);
        
            idopont = T(iii) + idofelbontas;    % majd kihagyjuk a kovetkezo "idofelbontas" hosszusagu idointervallumot is  

        end
    end
    
    % az igy letrehozott idopontbeli allapotokat pedig kozel idohelyesen
    % tudjuk abrazolni, ha az "idofelbontas" erteket megfeleloen
    % valasztottuk meg:
    for iii=1:(length(t))

        plot(x1(iii), y1(iii), 'bo',  x2(iii), y2(iii), 'ro', 'MarkerSize', 15)     % tomegpontok helye
        
        line([0 x1(iii)],[0, y1(iii)], 'Color', 'blue')                 % l1 palca
        line([x1(iii) x2(iii)],[y1(iii), y2(iii)], 'Color', 'red')      % l2 palca

        axis([-L +L -L +L])                             % L=l1+l2 kiterjedesu rendszer elferjen benne
        title( horzcat(num2str(t(iii),'%5.1f'),'s'))    % ido megjelenitese a cimben

        drawnow         % minden kirajzolas utan frissitjuk az abrat
     
        if(iii>1)
            
            % a kovetkezo abrazolast csak a megefelelo ido eltelte utan vegezzuk
            pause((t(iii)-t(iii-1)))
            
        end
    end
end



% amennyiben a megoldas kulonbozo ertekeinek idobeli valtozasat valamint
% nehany fazisterbeli vetuletet meg akarjuk jeleniteni:
if strcmp(abrazolas,'abrazolas_igen')

    Emin=-m1*g*l1-m2*g*(l1+l2);     % helyzeti energia 0 szintjet az origoba felveve a rendszer
                                    % stabil egyensulyi helyzetenek potencialis energiaja
    
    E=E-Emin;       % helyzeti energia nulla szintje origobol a stabil egyensulyi helyzetbe keruljon
    Emin=0;
    
    E1=2*(m1+m2)*g*l1;  % l1 palca atfordulasahzo szukseges minimalis energia
    E2=2*m2*g*l2;       % l2 palca atfordulasahzo szukseges minimalis energia
    
    Emax=E(1);          % kezdeti energia erteke
    
    energia_intervallum=max(max(abs(E)), max(E1,E2));   % energia abrazolashoz szukseges tartomany

    
    % feliratszovegek letrehozasa: megadott prarameterekbol, kezdeti
    % ertekekbol es a vizsgalt idotratomanybol:
    
    cim1=horzcat('m1=',num2str(m1),'kg',...
                '    m2=',num2str(m2),'kg',...
                '    l1=',num2str(l1),'m',...
                '    l2=',num2str(l2),'m',...
                '    k1=',num2str(k1),'kg/s',...
                '    k2=',num2str(k2),'kg/s' );

    cim2=horzcat('\phi1_0=',num2str(initcond(1)),'rad',...
                '    \omega1_0=',num2str(initcond(2)),'rad/s',...
                '    \phi2_0=',num2str(initcond(3)),'rad',...
                '    \omega2_0=',num2str(initcond(4)),'rad/s' );
            
    cim3=horzcat('E_0=',num2str(Emax),'J', '        t=', num2str(tinterval(1)),'...', num2str(tinterval(2)),'s');
            
    

    % fi1 idofuggesenek abrazolasa (2*pi csonkolas nelkul):
    figure(4)
    plot(T, FI(:,1),'b')
    legend('\phi1')
    xlabel('t [s]')
    ylabel('\phi1 [rad]')
    title({cim1, cim2, cim3});

    % fi2 idofuggesenek abrazolasa (2*pi csonkolas nelkul):
    figure(5)
    plot(T, FI(:,3),'r')
    legend('\phi2')
    xlabel('t [s]')
    ylabel('\phi2 [rad]')
    title({cim1, cim2, cim3});

    % omega1 idofuggesenek abrazolasa:
    figure(6)
    plot(T, FI(:,2),'b')
    legend('\omega1')
    xlabel('t [s]')
    ylabel('\omega1 [rad/s]')
    title({cim1, cim2, cim3});

    % omega2 idofuggesenek abrazolasa:
    figure(7)
    plot(T, FI(:,4),'r')
    legend('\omega2')
    xlabel('t [s]')
    ylabel('\omega2 [rad/s]')
    title({cim1, cim2, cim3});


    % fi1-fi2 abrazolasa (2*pi csonkolas nelkul):
    figure(8)
    plot(FI(:,1), FI(:,3),'k')
    legend('\phi1-\phi2')
    xlabel('\phi1 [rad]')
    ylabel('\phi2 [rad]')
    title({cim1, cim2, cim3});

    % omega1-omega2 abrazolasa
    figure(9)
    plot(FI(:,2), FI(:,4),'k')
    legend('\omega1-\omega2')
    xlabel('\omega1 [rad/s]')
    ylabel('\omega2 [rad/s]')
    title({cim1, cim2, cim3});

    % fi1-fi2-omega1 abrazolasa (2*pi csonkolassal):
    figure(10)
    plot3(mod(FI(:,1)+pi,2*pi), mod(FI(:,3)+pi, 2*pi), FI(:,2), 'k.', 'MarkerSize', 1)
    legend('\phi1-\phi2-\omega1')
    xlabel('\phi1 [rad]')
    ylabel('\phi2 [rad]')
    zlabel('\omega1 [rad/s]')
    title({cim1, cim2, cim3});

    % fi1-fi2-omega2 abrazolasa (2*pi csonkolassal):
    figure(11)
    plot3(mod(FI(:,1)+pi, 2*pi), mod(FI(:,3)+pi, 2*pi), FI(:,4), 'k.', 'MarkerSize', 1)
    legend('\phi1-\phi2-\omega2')
    xlabel('\phi1 [rad]')
    ylabel('\phi2 [rad]')
    zlabel('\omega2 [rad/s]')
    title({cim1, cim2, cim3});
    
    
    
    % kezdo helyzet abrazolasa:
    figure(2)
    plot(X1(1), Y1(1), 'bo',  X2(1), Y2(1), 'ro', 'MarkerSize', 15)
    line([0 X1(1)],[0, Y1(1)], 'Color', 'blue')
    line([X1(1) X2(1)],[Y1(1), Y2(1)], 'Color', 'red')
    axis([-L +L -L +L])
    title({cim1, cim2, cim3, 'kezdeti helyzet'});
    
    % osszes mechanikai energia abrazolasa az ido fuggvenyeben:
    % k1, k2 > 0 esetben az energia disszipaciojanak megfigyelese erdekeben, 
    % k1=0, k2=0 konzervativ esetben osszenergia allandosaganak tesztelese
    % erdekeben:
    figure(3)
    plot(T, E, 'k')
    line([T(1) T(end)],[Emax Emax], 'LineStyle', '--', 'Color', 'red')
    line([T(1) T(end)],[Emin Emin], 'LineStyle', '--', 'Color', 'blue')
    line([T(1) T(end)],[E1 E1], 'LineStyle', ':', 'Color', 'green')
    line([T(1) T(end)],[E2 E2], 'LineStyle', ':', 'Color', 'cyan')
    title({cim1, cim2, cim3});
    legend('mechanikai energia', 'kezdeti helyzet energiája', 'stabil egyensúlyi helyzet energiája', 'l1 pálca átfordulásához min. energia', 'l2 pálca átfordulásához min. energia', 'Location', 'SouthEast' )
    xlabel('t [s]')
    ylabel('E [J]')
    ylim(1.2*[-energia_intervallum, energia_intervallum])

    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dy=dife(t, y, m1, m2, l1, l2, k1, k2)
% matlab beepitett ode megoldo mukodtetesehez szukseges
% kettosingat altalanos fi1 es fi2 koordinatakkal leiro
% differencialegyenletrendszer matrixa,
% Lagrange fuggvenybol es nemkonzervativ altalanos erokomponensekbol
% levezetve:

global g

% fi1    = y(1)
% omega1 = y(2)
% fi2    = y(3)
% omega2 = y(4)

dy=[
    y(2);
        
    ((m2*l1^2*sin(y(3)-y(1))*cos(y(3)-y(1))*(y(2))^2+...
      m2*l1*l2*sin(y(3)-y(1))*(y(4))^2+...
      (k2*l1^2*(cos(y(3)-y(1)))^2-(k1+k2)*l2^2)*y(2)+...
      m2*l1*g*sin(y(3))*cos(y(3)-y(1))-(m1+m2)*g*l1*sin(y(1)))/...
      (l1^2*(m1+m2*(sin(y(3)-y(1)))^2)));    
        
    y(4);
        
    ((-m2*(m1+m2)*l1^2*sin(y(3)-y(1))*(y(2))^2-...
      m2^2*l1*l2*sin(y(3)-y(1))*cos(y(3)-y(1))*(y(4))^2-...
      ((m1+m2)*k2*l1^2-m2*(k1+k2)*l2^2)*cos(y(3)-y(1))*y(2)-...
      (m1+m2*(sin(y(3)-y(1)))^2)*l1*l2*k2*y(4)+...
      m2*(m1+m2)*l1*g*(sin(y(1))*cos(y(3)-y(1))-sin(y(3))))/...
      (m2*l1*l2*(m1+m2*(sin(y(3)-y(1)))^2)));
    
    ];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pelda: m1=3kg, m2=2kg, l1=0.8m, l2=0.6m konzervativ esetben
% 1. palca atfordulasahoz szukseges minimalis energia:
% E1=78.48J
% 2. palca atfordulasahoz szukseges minimalis energia:
% E2=23.54J

% kettosinga([0 100], [0.1 0 1 0], 3, 2, 0.8, 0.6, 0.0, 0.0,'animacio_nem', 'abrazolas_igen');
% E=5.6J
% kettosinga([0 100], [0.1 0 2 0], 3, 2, 0.8, 0.6, 0.0, 0.0,'animacio_nem', 'abrazolas_igen');
% E=16.9J
% kettosinga([0 100], [0.1 0 2.5 0], 3, 2, 0.8, 0.6, 0.0, 0.0,'animacio_nem', 'abrazolas_igen');
% E=21.4J
%----------------------------
% kettosinga([0 100], [1 0 pi 0], 3, 2, 0.8, 0.6, 0.0, 0.0,'animacio_nem', 'abrazolas_igen');
% E=41.6J
% kettosinga([0 100], [1.5 0 pi 0], 3, 2, 0.8, 0.6, 0.0, 0.0,'animacio_nem', 'abrazolas_igen');
% E=60.0J
%----------------------------
% kettosinga([0 100], [2.1 0 pi 0], 3, 2, 0.8, 0.6, 0.0, 0.0,'animacio_nem', 'abrazolas_igen');
% E=82.6J
% kettosinga([0 100], [3.1 0 pi 0], 3, 2, 0.8, 0.6, 0.0, 0.0,'animacio_nem', 'abrazolas_igen');
% E=102.0J


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% disszipacio megfigyelese novekvo kozegellanalasokkal:
% kettosinga([0 100], [3.1 0 pi 0], 3, 2, 0.8, 0.6, 0.01, 0.01,'animacio_nem', 'abrazolas_igen');
% kettosinga([0 100], [3.1 0 pi 0], 3, 2, 0.8, 0.6, 0.1, 0.1,'animacio_nem', 'abrazolas_igen');
% kettosinga([0 100], [3.1 0 pi 0], 3, 2, 0.8, 0.6, 1, 1,'animacio_nem', 'abrazolas_igen');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------
% megoldasi modszer korlatai:
%-----------------------------

% konzervativ esetben energiamegmaradas vizsgalata kisebb energian:
% kettosinga([0 1000], [0.1 0 1 0], 3, 2, 0.8, 0.6, 0.0, 0.0,'animacio_nem', 'abrazolas_igen');
% energianovekedes 1000s alatt 7%

% konzervativ esetben energiamegmaradas vizsgalata nagyobb energian:
% kettosinga([0 1000], [3.1 0 pi 0], 3, 2, 0.8, 0.6, 0.0, 0.0,'animacio_nem', 'abrazolas_igen');
% energianovekedes 1000s alatt 21%


% megoldasi modszer es rendszer instabilitasa, k2 kozegellenallasi egyutthato tul nagy ertekei eseten:
% kettosinga([0 30], [3.1 0 pi 0], 3, 2, 0.8, 0.6, 1, 10,'animacio_nem', 'abrazolas_igen');
% kettosinga([0 30], [3.1 0 pi 0], 3, 2, 0.8, 0.6, 1, 100,'animacio_nem', 'abrazolas_igen');
% kettosinga([0 30], [3.1 0 pi 0], 3, 2, 0.8, 0.6, 1, 500,'animacio_nem', 'abrazolas_igen');







