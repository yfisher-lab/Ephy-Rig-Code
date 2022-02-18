function [stepArray] = summation(X,Y,Z,BaseDur,PulseDur,PostDur,Rate,ampGain)
% Syntax
InjectionBaseSamples = Rate*BaseDur; % Hz=samples/sec
InjectionPulseSamples = Rate*PulseDur;
InjectionPostSamples = Rate*PostDur;
%Initilising loop to be zero
Voltstep = 0;
CurrentToInject = X:Y:Z;
stepArray = [];
for i = 1:length(CurrentToInject)
    % loop
    Voltstep = CurrentToInject(i)/ampGain;
    %k = k+1; %makin some new columns

    Array_Base = [zeros(1,InjectionBaseSamples)]; %array Baseline values 0pA
    Array_Inj = Voltstep*[ones(1,InjectionPulseSamples)]; %array Injection Voltage values ?pA
    Array_Post = [zeros(1,InjectionPostSamples)]; %array Post-injection values 0pA

    stepArray = [stepArray, Array_Base,Array_Inj,Array_Post];
    %stepArray(:,i) = [Array_Base,Array_Inj,Array_Post]; %putting together ABC arrayzzz
end
stepArray = stepArray'
end