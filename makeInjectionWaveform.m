function [OutputArray]= makeInjectionWaveform (InjpA,BaseDur,PulseDur,PostDur,Rate,ampGain)
%Injects Current for given Duration(s)
 
% makeInjectionWaveform function to inject current
InjectionBaseSamples = Rate*BaseDur; % Hz=samples/sec
InjectionPulseSamples = Rate*PulseDur;
InjectionPostSamples = Rate*PostDur;

%Volts = ampGain*(InjpA/1000); %Voltage injection (1nA=1000pA)
Volts = InjpA/ampGain;

Array_Base = [zeros(1,InjectionBaseSamples)]; %array Baseline values 0pA
Array_Inj = Volts*[ones(1,InjectionPulseSamples)]; %array Injection Voltage values ?pA
Array_Post = [zeros(1,InjectionPostSamples)]; %array Post-injection values 0pA
OutputArray = [Array_Base,Array_Inj,Array_Post]; %putting together ABC arrayzzz

end