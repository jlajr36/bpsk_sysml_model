% BPSK System Execution Script
A = 2.0;                 % Signal Amplitude (V)
N_bit = 1000;            % Number of bits
pBer = 0.5;              % Equiprobable bits
muN = 0.0;               % Noise mean
xr = 0.0;                % Decision boundary (V)
sigma2N = 0.5;           % Noise variance

% Define qfunc using built-in erfc
qfunc = @(x) 0.5 * erfc(x / sqrt(2));

% Swimlane 1: BPSK Transmitter
Tx = A * (2 * (rand(N_bit, 1) < pBer) - 1);
SNR = 10 * log10(A^2 / (2 * sigma2N));

Aarr = linspace(0.5, 4.0, 15);
SNRdBarr = zeros(1, length(Aarr));
for i = 1:length(Aarr)
    SNRdBarr(i) = 10 * log10(Aarr(i)^2 / (2 * sigma2N));
end

% Swimlane 2: Channel Noise
gn = sqrt(sigma2N) * randn(N_bit, 1) + muN;

% Swimlane 3: BPSK Receiver
rx = Tx + gn;

yt = zeros(size(rx));
yt(rx > xr) = A;
yt(rx <= xr) = -A;
if size(yt, 1) ~= size(Tx, 1)
    yt = transpose(yt);
end

Ne = nnz(yt ~= Tx);
BER = Ne / N_bit;

BER_true = qfunc(A / sqrt(sigma2N));
BERTrueArr = zeros(1, length(Aarr));
for i = 1:length(Aarr)
    BERTrueArr(i) = qfunc(Aarr(i) / sqrt(sigma2N));
end

% Plotting
figure;
semilogy(SNRdBarr, BERTrueArr, '-o'); hold on;
scatter(SNR, BER, 30, '^', 'filled');
scatter(SNR, BER_true, 30, 'p', 'filled');
yline(0.01, 'k--');
legend('theoretical', 'simulation', 'true', 'BER=0.01');
xlabel('SNR (dB)'); ylabel('BER');