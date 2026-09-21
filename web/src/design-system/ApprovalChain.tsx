import { Badge } from './Badge';
import { Icons } from './Icons';
import { format } from './format';

/**
 * ApprovalChain — docs/design-system/components/ApprovalChain/README.md.
 *
 *   · every step is shown, including ones not reached yet, dimmed with `opacity-pending` — the
 *     user has to know in advance how many stages the document still has;
 *   · the current step carries a clock icon in the `warning` tone, so the signal is not colour
 *     alone;
 *   · delegation is never hidden: "Delegasiya: <ad>" is as important as the name itself;
 *   · after a rejected step the chain continues — resubmission runs the same chain;
 *   · role codes stay in their original form (PROCUREMENT_MANAGER); the permission model looks
 *     them up by that exact string.
 *
 * Approve / reject buttons are deliberately not part of this component — the screen places them.
 */
export interface ApprovalStep {
  stepNo: number;
  role: string;
  user?: string;
  decision?: 'PENDING' | 'APPROVED' | 'REJECTED';
  decidedAt?: string;
  comment?: string;
  delegatedFrom?: string;
}

export interface ApprovalChainProps {
  steps: ApprovalStep[];
  /** `proc_approval_instance.current_step`. Without it the first PENDING step is current. */
  currentStep?: number;
}

export function resolveCurrentStep(
  steps: ApprovalStep[],
  currentStep: number | undefined,
): number | undefined {
  if (currentStep !== undefined) return currentStep;
  return steps.find((s) => (s.decision ?? 'PENDING') === 'PENDING')?.stepNo;
}

export function ApprovalChain({ steps, currentStep }: ApprovalChainProps) {
  const current = resolveCurrentStep(steps, currentStep);

  return (
    <ol className="wms-chain" aria-label="Təsdiq zənciri">
      {steps.map((step, index) => {
        const decision = step.decision ?? 'PENDING';
        const isCurrent = step.stepNo === current && decision === 'PENDING';
        const isPending = decision === 'PENDING';

        let nodeClass = 'wms-chain__node';
        let icon = <span>{step.stepNo}</span>;
        if (decision === 'APPROVED') {
          nodeClass += ' wms-chain__node--approved';
          icon = Icons.check(14);
        } else if (decision === 'REJECTED') {
          nodeClass += ' wms-chain__node--rejected';
          icon = Icons.close(14);
        } else if (isCurrent) {
          nodeClass += ' wms-chain__node--current';
          icon = Icons.clock(14);
        }

        return (
          <li
            key={step.stepNo}
            className={`wms-chain__step${isPending && !isCurrent ? ' wms-chain__step--pending' : ''}`}
          >
            <div className="wms-chain__rail">
              <div className={nodeClass}>{icon}</div>
              {index < steps.length - 1 ? <div className="wms-chain__line" /> : null}
            </div>
            <div className="wms-chain__body">
              <div className="wms-chain__role">{step.role}</div>
              <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>
                <span className="wms-chain__name">{step.user ?? 'Təyin edilməyib'}</span>
                {decision === 'APPROVED' ? <Badge tone="success">Təsdiqlədi</Badge> : null}
                {decision === 'REJECTED' ? <Badge tone="danger">Rədd etdi</Badge> : null}
                {isCurrent ? <Badge tone="warning">Gözlənilir</Badge> : null}
                {isPending && !isCurrent ? <Badge tone="neutral">Növbədə</Badge> : null}
                {step.delegatedFrom ? (
                  <Badge tone="accent">{`Delegasiya: ${step.delegatedFrom}`}</Badge>
                ) : null}
                {step.decidedAt ? (
                  <span className="wms-chain__when">{format.dateTime(step.decidedAt)}</span>
                ) : null}
              </div>
              {step.comment ? <div className="wms-chain__comment">{step.comment}</div> : null}
            </div>
          </li>
        );
      })}
    </ol>
  );
}
