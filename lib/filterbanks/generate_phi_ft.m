function [phi_ft, energy_sum] = generate_phi_ft(psi_energy_sum,bank_spec)
%%
energy_sum = (psi_energy_sum + psi_energy_sum(end:-1:1)) / 2;
remainder = 1 - min(energy_sum,1);
phi_ft = zeros(size(energy_sum));
signal_dimension = length(bank_spec.size);
original_sizes = bank_spec.size;
switch signal_dimension
    case 1
        half_support_length = ...
            bank_spec.phi_bw_multiplier/2 * original_sizes/bank_spec.T;
        if bank_spec.phi.is_gaussian
            denominator = half_support_length*half_support_length / log(10);
            half_size = original_sizes / 2;
            half_support = 2:half_size;
            symmetric_support = original_sizes + 1 - half_support + 1;
            omegas = half_support - 1;
            half_gaussian = exp(- omegas .* omegas / denominator);
            phi_ft(half_support) = half_gaussian;
            phi_ft(symmetric_support) = half_gaussian;
            phi_ft(1+0) = 1;
            energy_sum = energy_sum + phi_ft;
        elseif bank_spec.phi.is_rectangular
            assert(strcmp(func2str(bank_spec.handle), 'finitediff_1d'));
            phi_ift = zeros(original_sizes, 1);
            half_ift_support = 1:(bank_spec.T/2);
            normalizer = sqrt(1+bank_spec.T) * sqrt(3);
            phi_ift(1 + half_ift_support) = 1 / normalizer;
            phi_ift(1 + end - half_ift_support) = 1 / normalizer;
            phi_ift(1+0) = 1 / normalizer;
            phi_ft = fft(phi_ift);
            energy_sum = energy_sum + phi_ft .* conj(phi_ft);
        elseif bank_spec.phi.is_by_substraction
            half_support = 2:half_support_length;
            symmetric_support = original_sizes + 1 - half_support + 1;
            sqrt_truncated_remainder = sqrt(remainder(half_support));
            phi_ft(half_support) = sqrt_truncated_remainder;
            phi_ft(symmetric_support) = sqrt_truncated_remainder;
            phi_ft(1+0) = 1;
            energy_sum(half_support) = max(energy_sum(half_support), 1);
            energy_sum(symmetric_support) = energy_sum(half_support);
            energy_sum(1+0) = 1;
        end
        % We must ensure that phi_ft is exactly zero at the frequency pi
        % in order to yield real results for real inputs.
        phi_ft(1+end/2) = 0;
    case 2
        error('2D phi not ready yet');
end
end
