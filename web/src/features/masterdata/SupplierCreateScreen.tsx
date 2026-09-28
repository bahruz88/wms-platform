import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { Alert, Button, Select, TextField } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { createSupplier, listCurrencyRates } from '@api/endpoints';
import { Card, DocumentPage, ErrorState, MetaGrid } from '@/components/Page';
import { RefPicker } from '@/components/RefPicker';

/**
 * New supplier.
 *
 * `isApprovedFoodSupplier` is the one switch here with teeth: without it a receipt of a `FOOD`
 * product from this supplier is refused (TOR §7, `422`). It is off by default — approval is a
 * document someone signs, not a box a data-entry clerk ticks in passing — and the form says what
 * turning it on permits.
 *
 * `code` cannot be changed later: purchase orders and price history quote it.
 */
export function SupplierCreateScreen() {
  const navigate = useNavigate();

  const [code, setCode] = useState('');
  const [name, setName] = useState('');
  const [taxId, setTaxId] = useState('');
  const [contactPerson, setContactPerson] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [address, setAddress] = useState('');
  const [bankDetails, setBankDetails] = useState('');
  const [currency, setCurrency] = useState('AZN');
  const [paymentTerms, setPaymentTerms] = useState('');
  const [deliveryTerms, setDeliveryTerms] = useState('');
  const [incoterms, setIncoterms] = useState('');
  const [isApprovedFoodSupplier, setIsApprovedFoodSupplier] = useState('false');

  const currencies = useApiPage<{ currency: string }>(
    ['currency-rates', 'supplier-create'],
    () => listCurrencyRates({ page: 1, size: 100 }),
    100,
    { retry: false },
  );

  const errors = {
    code:
      code.trim().length === 0
        ? 'Kod məcburidir.'
        : /^[A-Z0-9_-]+$/.test(code.trim())
          ? undefined
          : 'Kod yalnız böyük latın hərfləri, rəqəm, «-» və «_» ola bilər.',
    name: name.trim().length === 0 ? 'Ad məcburidir.' : undefined,
    email:
      email.trim().length === 0 || /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())
        ? undefined
        : 'E-poçt ünvanı düzgün deyil.',
  };
  const blockers = Object.entries(errors).filter(([, v]) => v !== undefined);

  const create = useMutation({
    mutationFn: () =>
      createSupplier({
        code: code.trim(),
        name: name.trim(),
        currency,
        isApprovedFoodSupplier: isApprovedFoodSupplier === 'true',
        ...(taxId.trim() ? { taxId: taxId.trim() } : {}),
        ...(contactPerson.trim() ? { contactPerson: contactPerson.trim() } : {}),
        ...(phone.trim() ? { phone: phone.trim() } : {}),
        ...(email.trim() ? { email: email.trim() } : {}),
        ...(address.trim() ? { address: address.trim() } : {}),
        ...(bankDetails.trim() ? { bankDetails: bankDetails.trim() } : {}),
        ...(paymentTerms.trim() ? { paymentTerms: paymentTerms.trim() } : {}),
        ...(deliveryTerms.trim() ? { deliveryTerms: deliveryTerms.trim() } : {}),
        ...(incoterms.trim() ? { incoterms: incoterms.trim() } : {}),
      }),
    onSuccess: (doc) => navigate(`/master-data/suppliers/${(doc as { id: number }).id}`),
  });

  const currencyOptions = Array.from(
    new Set(['AZN', ...(currencies.data?.items ?? []).map((r) => r.currency)]),
  ).map((c) => ({ value: c, label: c }));

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/master-data/products">Sorğu kitabçaları</Link> ·{' '}
          <Link to="/master-data/suppliers">Təchizatçılar</Link>
        </>
      }
      docNo="Yeni təchizatçı"
      mono={false}
      status={isApprovedFoodSupplier === 'true' ? 'APPROVED' : 'DRAFT'}
      actions={
        <>
          <Button variant="ghost" onClick={() => navigate('/master-data/suppliers')}>
            İmtina
          </Button>
          <Button
            variant="primary"
            loading={create.isPending}
            disabled={blockers.length > 0}
            title={blockers.length > 0 ? 'Məcburi sahələri doldurun' : undefined}
            onClick={() => create.mutate()}
          >
            Təchizatçı yarat
          </Button>
        </>
      }
    >
      {create.isError ? <ErrorState error={create.error} /> : null}

      <Alert tone="info" title="Kod sonradan dəyişmir">
        Sifarişlər və qiymət tarixçəsi təchizatçıya kodu ilə istinad edir.
      </Alert>

      {isApprovedFoodSupplier === 'true' ? (
        <Alert tone="warning" title="Qida təsdiqi verilir">
          Bu açıq olduqda bu təchizatçıdan qida məhsulu qəbul edilə bilər. Təsdiq imzalanan
          sənəddir — sertifikatı təchizatçı kartına əlavə edin.
        </Alert>
      ) : null}

      <Card title="Təchizatçı kartı">
        <MetaGrid columns={6}>
          <TextField
            label="Kod"
            required
            mono
            value={code}
            error={code.length > 0 ? errors.code : undefined}
            hint="Sonradan dəyişmir."
            onChange={(e) => setCode(e.target.value)}
          />
          <div style={{ gridColumn: 'span 2' }}>
            <TextField
              label="Ad"
              required
              value={name}
              error={name.length > 0 ? errors.name : undefined}
              onChange={(e) => setName(e.target.value)}
            />
          </div>
          <TextField
            label="VÖEN"
            mono
            value={taxId}
            onChange={(e) => setTaxId(e.target.value)}
          />
          <RefPicker
            label="Valyuta"
            required
            value={currency}
            placeholder="Valyuta"
            operation="GET /masterdata/currency-rates"
            listError={currencies.error}
            options={currencyOptions}
            onChange={setCurrency}
          />
          <Select
            label="Qida təsdiqi"
            value={isApprovedFoodSupplier}
            hint="Qida məhsulunun qəbulu buna bağlıdır."
            options={[
              { value: 'false', label: 'Yoxdur' },
              { value: 'true', label: 'Var' },
            ]}
            onChange={(e) => setIsApprovedFoodSupplier(e.target.value)}
          />
        </MetaGrid>
      </Card>

      <Card title="Əlaqə">
        <MetaGrid columns={4}>
          <TextField
            label="Əlaqədar şəxs"
            value={contactPerson}
            onChange={(e) => setContactPerson(e.target.value)}
          />
          <TextField label="Telefon" mono value={phone} onChange={(e) => setPhone(e.target.value)} />
          <TextField
            label="E-poçt"
            mono
            value={email}
            error={email.length > 0 ? errors.email : undefined}
            onChange={(e) => setEmail(e.target.value)}
          />
          <TextField
            label="Ünvan"
            value={address}
            onChange={(e) => setAddress(e.target.value)}
          />
        </MetaGrid>
      </Card>

      <Card title="Kommersiya şərtləri">
        <MetaGrid columns={4}>
          <TextField
            label="Ödəniş şərtləri"
            value={paymentTerms}
            hint="Məsələn «30 gün sonra»."
            onChange={(e) => setPaymentTerms(e.target.value)}
          />
          <TextField
            label="Çatdırılma şərtləri"
            value={deliveryTerms}
            onChange={(e) => setDeliveryTerms(e.target.value)}
          />
          <TextField
            label="Incoterms"
            mono
            value={incoterms}
            onChange={(e) => setIncoterms(e.target.value)}
          />
          <div style={{ gridColumn: 'span 2' }}>
            <TextField
              label="Bank məlumatları"
              value={bankDetails}
              onChange={(e) => setBankDetails(e.target.value)}
            />
          </div>
        </MetaGrid>
      </Card>
    </DocumentPage>
  );
}
