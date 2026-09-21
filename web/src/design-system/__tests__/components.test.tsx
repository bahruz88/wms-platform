import { describe, expect, it, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Alert } from '../Alert';
import { ApprovalChain, resolveCurrentStep, type ApprovalStep } from '../ApprovalChain';
import { Badge } from '../Badge';
import { Button } from '../Button';
import { Dialog } from '../Dialog';
import { DocStatusBadge } from '../DocStatusBadge';
import { Field } from '../Field';
import { Icons } from '../Icons';
import { KpiCard } from '../KpiCard';
import { QtyUomInput } from '../QtyUomInput';
import { Select } from '../Select';
import { TextField } from '../TextField';
import { format } from '../format';
import { RAW } from './testUtils';

describe('Button', () => {
  it('keeps its width while loading — the label stays in the flow, hidden', () => {
    const { rerender, container } = render(<Button variant="primary">Post et</Button>);
    const before = container.querySelector('button')?.textContent;
    rerender(
      <Button variant="primary" loading>
        Post et
      </Button>,
    );
    // The label is still laid out (so the width does not change) but hidden from the a11y tree.
    const hidden = container.querySelector('[aria-hidden="true"]');
    expect(hidden?.textContent).toBe(before);
    expect(screen.getByTestId('wms-spinner')).toBeInTheDocument();
  });

  it('disables itself and reports aria-busy while loading, preventing a double POST', async () => {
    const onClick = vi.fn();
    render(
      <Button loading onClick={onClick}>
        Post et
      </Button>,
    );
    const button = screen.getByRole('button');
    expect(button).toBeDisabled();
    expect(button).toHaveAttribute('aria-busy', 'true');
    await userEvent.click(button);
    expect(onClick).not.toHaveBeenCalled();
  });

  it('warns in development when a disabled button has no reason', () => {
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    render(<Button disabled>Post et</Button>);
    expect(warn).toHaveBeenCalledWith(expect.stringContaining('disabled button needs a reason'));
    warn.mockRestore();
  });

  it('carries the reason in title when one is given', () => {
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    render(
      <Button disabled title="Lokasiya sayım üçün dondurulub">
        Post et
      </Button>,
    );
    expect(screen.getByRole('button')).toHaveAttribute('title', 'Lokasiya sayım üçün dondurulub');
    expect(warn).not.toHaveBeenCalled();
    warn.mockRestore();
  });

  it('applies the variant and size classes from bundle.css', () => {
    const { container } = render(
      <Button variant="danger" size="sm">
        Storno et
      </Button>,
    );
    const button = container.querySelector('button');
    expect(button).toHaveClass('wms-btn', 'wms-btn--danger', 'wms-btn--sm');
  });
});

describe('Badge', () => {
  it('requires text — colour alone carries no meaning', () => {
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    render(<Badge tone="danger" dot />);
    expect(warn).toHaveBeenCalledWith(expect.stringContaining('text is mandatory'));
    warn.mockRestore();
  });

  it('renders the dot as an accompaniment to the word, not instead of it', () => {
    const { container } = render(
      <Badge tone="success" dot>
        Aktiv
      </Badge>,
    );
    expect(container.querySelector('.wms-badge__dot')).toHaveAttribute('aria-hidden', 'true');
    expect(container.textContent).toContain('Aktiv');
  });
});

describe('DocStatusBadge', () => {
  it('translates the ENUM and keeps the raw value in title for support', () => {
    render(<DocStatusBadge status="PENDING_APPROVAL" />);
    const badge = screen.getByTitle('PENDING_APPROVAL');
    expect(badge.textContent).toContain('Təsdiq gözləyir');
  });

  it('maps tones by outcome: posted is success, rejected is danger, draft is neutral', () => {
    const { container, rerender } = render(<DocStatusBadge status="POSTED" />);
    expect(container.querySelector('.wms-badge--success')).toBeInTheDocument();
    rerender(<DocStatusBadge status="REJECTED" />);
    expect(container.querySelector('.wms-badge--danger')).toBeInTheDocument();
    rerender(<DocStatusBadge status="DRAFT" />);
    expect(container.querySelector('.wms-badge--neutral')).toBeInTheDocument();
  });

  it('shows an unknown ENUM verbatim rather than leaving a gap', () => {
    render(<DocStatusBadge status="SOME_NEW_STATE" />);
    expect(screen.getByTitle('SOME_NEW_STATE').textContent).toContain('SOME_NEW_STATE');
  });

  it('exposes the ENUM map so new statuses can be added in one place', () => {
    expect(DocStatusBadge.statuses.POSTED?.[0]).toBe('Post edilib');
    expect(DocStatusBadge.statuses.EXPIRED?.[1]).toBe('danger');
  });

  it('never uppercases interface text', () => {
    render(<DocStatusBadge status="IN_TRANSIT" />);
    expect(screen.getByTitle('IN_TRANSIT').textContent).toContain('Yoldadır');
  });
});

describe('Alert', () => {
  it('shows the RFC 7807 code — support works with it', () => {
    render(
      <Alert
        tone="danger"
        title="Kifayət qədər stok yoxdur"
        code="INSUFFICIENT_STOCK"
        traceId="00-abc-01"
      >
        Chicken Strips: mövcud 45,0000 KG, tələb olunan 60,0000 KG
      </Alert>,
    );
    expect(screen.getByText('INSUFFICIENT_STOCK')).toBeInTheDocument();
    expect(screen.getByText('trace 00-abc-01')).toBeInTheDocument();
  });

  it('announces a danger alert immediately and a status alert politely', () => {
    const { rerender } = render(<Alert tone="danger" title="Xəta" />);
    expect(screen.getByRole('alert')).toBeInTheDocument();
    rerender(<Alert tone="info" title="Məlumat" />);
    expect(screen.getByRole('status')).toBeInTheDocument();
  });

  it('only offers a close control when onClose is given', () => {
    const onClose = vi.fn();
    const { rerender } = render(<Alert tone="danger" title="Xəta" />);
    expect(screen.queryByRole('button', { name: 'Bağla' })).not.toBeInTheDocument();
    rerender(<Alert tone="info" title="Məlumat" onClose={onClose} />);
    expect(screen.getByRole('button', { name: 'Bağla' })).toBeInTheDocument();
  });
});

describe('Field, TextField and Select', () => {
  it('hides the hint as soon as an error is shown', () => {
    const { rerender } = render(<TextField label="SKU" hint="Unikal olmalıdır" value="" />);
    expect(screen.getByText('Unikal olmalıdır')).toBeInTheDocument();
    rerender(<TextField label="SKU" hint="Unikal olmalıdır" error="Bu SKU artıq var" value="" />);
    expect(screen.queryByText('Unikal olmalıdır')).not.toBeInTheDocument();
    expect(screen.getByText('Bu SKU artıq var')).toBeInTheDocument();
  });

  it('marks the field invalid and turns the border danger', () => {
    const { container } = render(<TextField label="SKU" error="Xəta" value="" />);
    expect(screen.getByRole('textbox')).toHaveAttribute('aria-invalid', 'true');
    expect(container.querySelector('.wms-field--error')).toBeInTheDocument();
  });

  it('adds the required marker from the prop, not from the label text', () => {
    const { container } = render(<Field label="Lokasiya" required />);
    expect(container.querySelector('.wms-field__req')?.textContent).toBe('*');
    expect(container.querySelector('label')?.textContent).toBe('Lokasiya*');
  });

  it('uses the mono family for identifier fields', () => {
    render(<TextField label="Barkod" mono value="4780000000001" />);
    expect(screen.getByRole('textbox')).toHaveClass('wms-num');
  });

  it('keeps a disallowed select option in the list, disabled with its reason', () => {
    render(
      <Select
        label="Lokasiya"
        value=""
        options={[
          { value: '1', label: 'Mərkəzi anbar' },
          { value: '2', label: 'Non-Food WH (qida qəbul etmir)', disabled: true },
        ]}
      />,
    );
    const option = screen.getByRole('option', { name: 'Non-Food WH (qida qəbul etmir)' });
    expect(option).toBeInTheDocument();
    expect(option).toBeDisabled();
  });
});

describe('QtyUomInput', () => {
  const uoms = [
    { id: 1, code: 'G', factorToBase: 1 },
    { id: 2, code: 'KG', factorToBase: 1000 },
  ];

  it('shows the base equivalent when the chosen unit is not the base one', () => {
    render(
      <QtyUomInput label="Miqdar" qty="8" uomId={2} uoms={uoms} baseUomCode="G" decimals={4} />,
    );
    expect(screen.getByText('= 8 000,0000 G · əmsal 1 000,0000', RAW)).toBeInTheDocument();
  });

  it('shows no base line when the unit is already the base one', () => {
    const { container } = render(
      <QtyUomInput label="Miqdar" qty="8" uomId={1} uoms={uoms} baseUomCode="G" />,
    );
    expect(container.querySelector('.wms-qty__base')).not.toBeInTheDocument();
  });

  it('does not convert the figure when the unit changes — only the base line moves', async () => {
    const onUomChange = vi.fn();
    const onQtyChange = vi.fn();
    render(
      <QtyUomInput
        label="Miqdar"
        qty="8"
        uomId={2}
        uoms={uoms}
        baseUomCode="G"
        onUomChange={onUomChange}
        onQtyChange={onQtyChange}
      />,
    );
    await userEvent.selectOptions(screen.getByLabelText('Ölçü vahidi'), '1');
    expect(onUomChange).toHaveBeenCalledWith('1', expect.anything());
    expect(onQtyChange).not.toHaveBeenCalled();
  });

  it('refuses a negative quantity — the sign comes from the document type', async () => {
    const onQtyChange = vi.fn();
    render(<QtyUomInput label="Miqdar" qty="" uoms={uoms} onQtyChange={onQtyChange} />);
    const input = screen.getByRole('textbox');
    await userEvent.type(input, '-5');
    expect(onQtyChange).not.toHaveBeenCalledWith('-', expect.anything());
    expect(onQtyChange.mock.calls.every(([value]) => !String(value).startsWith('-'))).toBe(true);
  });

  it('right-aligns the figure in the mono family', () => {
    const { container } = render(<QtyUomInput label="Miqdar" qty="8" uoms={uoms} />);
    expect(container.querySelector('.wms-qty__num')).toBeInTheDocument();
  });
});

describe('KpiCard', () => {
  it('formats the figure with the brand book rules', () => {
    render(<KpiCard label="Anbar dəyəri" value="1284.5" decimals={2} unit="AZN" hint="Cari" />);
    expect(screen.getByText('1 284,50', RAW)).toBeInTheDocument();
    expect(screen.getByText('AZN')).toBeInTheDocument();
  });

  it('signs the delta and colours it by direction', () => {
    const { container } = render(
      <KpiCard label="Tullantı" value="12" delta={-4.5} hint="Keçən aya görə" />,
    );
    expect(screen.getByText('−4,5', RAW)).toBeInTheDocument();
    expect(container.querySelector('.wms-delta--down')).toBeInTheDocument();
  });

  it('lets the screen override the direction — falling waste is good news', () => {
    const { container } = render(
      <KpiCard label="Tullantı" value="12" delta={-4.5} deltaTone="up" hint="Keçən aya görə" />,
    );
    expect(container.querySelector('.wms-delta--up')).toBeInTheDocument();
  });

  it('warns when a delta is given without a comparison base', () => {
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    render(<KpiCard label="Tullantı" value="12" delta={-4.5} />);
    expect(warn).toHaveBeenCalledWith(expect.stringContaining('`delta` without a `hint`'));
    warn.mockRestore();
  });

  it('passes a pre-formatted string through untouched', () => {
    render(<KpiCard label="Anbar dəyəri" value="1 284,50 AZN" hint="Cəm" />);
    expect(screen.getByText('1 284,50 AZN')).toBeInTheDocument();
  });
});

describe('ApprovalChain', () => {
  const steps: ApprovalStep[] = [
    {
      stepNo: 1,
      role: 'PROCUREMENT_OFFICER',
      user: 'procurement',
      decision: 'APPROVED',
      decidedAt: '2026-09-20T10:00:00Z',
    },
    {
      stepNo: 2,
      role: 'PROCUREMENT_MANAGER',
      user: 'manager',
      decision: 'PENDING',
      delegatedFrom: 'director',
    },
    { stepNo: 3, role: 'ADMIN', decision: 'PENDING' },
  ];

  it('renders every step, including ones not reached yet', () => {
    render(<ApprovalChain steps={steps} />);
    expect(screen.getByText('PROCUREMENT_OFFICER')).toBeInTheDocument();
    expect(screen.getByText('PROCUREMENT_MANAGER')).toBeInTheDocument();
    expect(screen.getByText('ADMIN')).toBeInTheDocument();
  });

  it('never hides a delegation', () => {
    render(<ApprovalChain steps={steps} />);
    expect(screen.getByText('Delegasiya: director')).toBeInTheDocument();
  });

  it('dims steps that are still queued but not the current one', () => {
    const { container } = render(<ApprovalChain steps={steps} />);
    const pending = container.querySelectorAll('.wms-chain__step--pending');
    expect(pending).toHaveLength(1);
    expect(pending[0]?.textContent).toContain('ADMIN');
  });

  it('keeps role codes in their original form for the permission model', () => {
    render(<ApprovalChain steps={steps} />);
    expect(screen.getByText('PROCUREMENT_MANAGER')).toBeInTheDocument();
  });

  it('treats the first PENDING step as current when currentStep is not given', () => {
    expect(resolveCurrentStep(steps, undefined)).toBe(2);
    expect(resolveCurrentStep(steps, 3)).toBe(3);
  });

  it('places no decision buttons inside the component — the screen owns those', () => {
    const { container } = render(<ApprovalChain steps={steps} />);
    expect(container.querySelectorAll('button')).toHaveLength(0);
  });
});

describe('Dialog', () => {
  it('renders nothing while closed', () => {
    const { container } = render(<Dialog open={false} title="Storno et" />);
    expect(container.firstChild).toBeNull();
  });

  it('is a modal dialog with the title as its accessible name', () => {
    render(<Dialog open title="Qəbulu post edim?" />);
    expect(screen.getByRole('dialog', { name: 'Qəbulu post edim?' })).toHaveAttribute(
      'aria-modal',
      'true',
    );
  });

  it('closes on the scrim and on Escape when onClose is given', async () => {
    const onClose = vi.fn();
    const { container } = render(<Dialog open title="Storno et" onClose={onClose} />);
    await userEvent.click(container.querySelector('.wms-scrim') as Element);
    expect(onClose).toHaveBeenCalledTimes(1);
    await userEvent.keyboard('{Escape}');
    expect(onClose).toHaveBeenCalledTimes(2);
  });

  it('cannot be dismissed when onClose is withheld — data-loss case', async () => {
    const { container } = render(<Dialog open title="Storno et" />);
    await userEvent.click(container.querySelector('.wms-scrim') as Element);
    expect(screen.getByRole('dialog')).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Bağla' })).not.toBeInTheDocument();
  });

  it('moves focus to the first interactive element on open', () => {
    render(
      <Dialog open title="Storno et" footer={<button type="button">Storno et</button>}>
        <input aria-label="Səbəb" />
      </Dialog>,
    );
    expect(screen.getByLabelText('Səbəb')).toHaveFocus();
  });
});

describe('Icons and format', () => {
  it('exposes the seven bundle icons, all inheriting currentColor', () => {
    const names = ['chevron', 'close', 'check', 'warn', 'info', 'clock', 'arrow'] as const;
    names.forEach((name) => {
      const { container } = render(<div>{Icons[name](16)}</div>);
      const svg = container.querySelector('svg');
      expect(svg).toHaveAttribute('stroke', 'currentColor');
      expect(svg).toHaveAttribute('aria-hidden', 'true');
    });
  });

  it('matches the format helper signatures from index.d.ts', () => {
    expect(format.number(1234.5, 4)).toBe('1 234,5000');
    expect(format.signed(-12, 4)).toBe('−12,0000');
    expect(format.date('2026-09-20')).toBe('20.09.2026');
    expect(format.dateTime(new Date(2026, 8, 20, 9, 5))).toBe('20.09.2026 09:05');
  });
});
