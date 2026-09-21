import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import { VarianceIndicator, computeVariance } from '../VarianceIndicator';
import { RAW } from './testUtils';

/** components/VarianceIndicator/README.md. */
describe('VarianceIndicator', () => {
  it('shows "Səbəb kodu yoxdur" when a variance has no reason code', () => {
    render(<VarianceIndicator book="100" counted="94" uom="KG" />);
    expect(screen.getByText('Səbəb kodu yoxdur')).toBeInTheDocument();
  });

  it('drops the badge once a reason code is chosen', () => {
    render(<VarianceIndicator book="100" counted="94" uom="KG" reasonCode="WST-01" />);
    expect(screen.queryByText('Səbəb kodu yoxdur')).not.toBeInTheDocument();
  });

  it('does not demand a reason when the variance is zero', () => {
    render(<VarianceIndicator book="100" counted="100" uom="KG" />);
    expect(screen.queryByText('Səbəb kodu yoxdur')).not.toBeInTheDocument();
  });

  it('always signs the difference', () => {
    const { rerender } = render(<VarianceIndicator book="100" counted="106" decimals={3} />);
    expect(screen.getByText('+6,000')).toBeInTheDocument();
    rerender(<VarianceIndicator book="3000" counted="400" decimals={3} />);
    expect(screen.getByText('−2 600,000', RAW)).toBeInTheDocument();
  });

  it('keeps zero variance neutral — it is the expected result, not an achievement', () => {
    const { container } = render(<VarianceIndicator book="100" counted="100" />);
    expect(container.querySelector('.wms-variance__val--zero')).toBeInTheDocument();
    expect(container.querySelector('.wms-variance__val--over')).not.toBeInTheDocument();
  });

  it('raises "Təsdiq tələb edir" above the inv_setting threshold', () => {
    const { rerender } = render(<VarianceIndicator book="100" counted="101" thresholdPct={2} />);
    expect(screen.queryByText('Təsdiq tələb edir')).not.toBeInTheDocument();
    rerender(<VarianceIndicator book="100" counted="110" thresholdPct={2} />);
    expect(screen.getByText('Təsdiq tələb edir')).toBeInTheDocument();
  });

  it('treats book = 0 as 100 % and always requiring approval', () => {
    render(<VarianceIndicator book="0" counted="12" thresholdPct={50} />);
    expect(screen.getByText('+100,00 %')).toBeInTheDocument();
    expect(screen.getByText('Təsdiq tələb edir')).toBeInTheDocument();
  });

  it('computes the variance through Decimal, not through a float', () => {
    const result = computeVariance('0.3', '0.1', 2, 'R');
    expect(result.variance.toFixed(4)).toBe('-0.2000');
    expect(result.pct?.toFixed(4)).toBe('-66.6667');
  });
});
