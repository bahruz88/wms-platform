import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert, Badge, Button, Select, TextField } from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  getUser,
  listLocations,
  listRoles,
  setUserLocations,
  setUserRoles,
  updateUser,
  type Location,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { Card, DocumentPage, ErrorState, LoadingState, Meta, MetaGrid } from '@/components/Page';

/**
 * A user's card: their details, the roles they hold, and the locations they may see.
 *
 * The location list is the dangerous one. An **empty** list means every location — the one place in
 * the platform where sending less grants more — so clearing it is a deliberate act with its own
 * confirmation, not a side effect of removing the last row. A branch worker whose scope is emptied
 * by accident would silently gain the whole company's stock.
 *
 * Roles and locations are separate calls with their own row versions, so each is saved on its own
 * button. Batching them would make a failure halfway through hard to explain.
 */
type User = {
  id: number;
  externalId: string;
  username: string;
  fullName: string;
  email?: string | null;
  phone?: string | null;
  isActive: boolean;
  roles: Array<{ id: number; code: string; name: string; isSystem: boolean }>;
  locationIds: number[];
  audit: { rowVersion: number };
};

export function UserDetailScreen() {
  const { id } = useParams();
  const userId = Number(id);
  const { can } = useAuth();
  const queryClient = useQueryClient();

  const user = useApiQuery<User>(['user', userId], () => getUser(userId) as Promise<User>);
  const roles = useApiPage<{ id: number; code: string; name: string; isSystem: boolean }>(
    ['roles', 'user-detail'],
    () => listRoles(),
    200,
    { retry: false },
  );
  const locations = useApiPage<Location>(['locations', 'user-detail'], () => listLocations({}), 200, {
    retry: false,
  });

  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [isActive, setIsActive] = useState('true');
  const [roleIds, setRoleIds] = useState<number[]>([]);
  const [locationIds, setLocationIds] = useState<number[]>([]);
  const [confirmUnrestricted, setConfirmUnrestricted] = useState(false);

  // Seeded from the server's answer; every save refetches and re-seeds, so the form never drifts
  // from the row version it will send.
  useEffect(() => {
    const doc = user.data;
    if (!doc) return;
    setFullName(doc.fullName);
    setEmail(doc.email ?? '');
    setPhone(doc.phone ?? '');
    setIsActive(String(doc.isActive));
    setRoleIds(doc.roles.map((r) => r.id));
    setLocationIds(doc.locationIds);
    setConfirmUnrestricted(false);
  }, [user.data]);

  const refresh = () => {
    void queryClient.invalidateQueries({ queryKey: ['user', userId] });
    void queryClient.invalidateQueries({ queryKey: ['users'] });
  };

  const rowVersion = user.data?.audit.rowVersion ?? 1;

  const saveDetails = useMutation({
    mutationFn: () =>
      updateUser(userId, {
        fullName: fullName.trim(),
        isActive: isActive === 'true',
        rowVersion,
        ...(email.trim() ? { email: email.trim() } : {}),
        ...(phone.trim() ? { phone: phone.trim() } : {}),
      }),
    onSuccess: refresh,
  });

  const saveRoles = useMutation({
    mutationFn: () => setUserRoles(userId, roleIds, rowVersion),
    onSuccess: refresh,
  });

  const saveLocations = useMutation({
    mutationFn: () => setUserLocations(userId, locationIds, rowVersion),
    onSuccess: refresh,
  });

  if (user.isLoading) return <LoadingState />;
  if (user.isError)
    return (
      <DocumentPage breadcrumb="İdarəetmə · İstifadəçilər" docNo={`#${userId}`}>
        <ErrorState error={user.error} onRetry={() => void user.refetch()} />
      </DocumentPage>
    );
  const doc = user.data;
  if (!doc) return null;

  const manage = can('iam.user.manage');
  const unrestricted = locationIds.length === 0;
  const realLocations = (locations.data?.items ?? []).filter((l) => !l.isVirtual);

  const toggle = (list: number[], value: number): number[] =>
    list.includes(value) ? list.filter((v) => v !== value) : [...list, value];

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/admin/users">İdarəetmə</Link> · <Link to="/admin/users">İstifadəçilər</Link>
        </>
      }
      docNo={doc.username}
      status={doc.isActive ? 'ACTIVE' : 'CLOSED'}
      context={doc.roles.map((r) => r.code).join(', ') || 'rol yoxdur'}
    >
      <Card title="İstifadəçi">
        <MetaGrid columns={6}>
          <Meta
            label="Keycloak subject"
            value={<span className="wms-num wms-small">{doc.externalId}</span>}
          />
          <div style={{ gridColumn: 'span 2' }}>
            <TextField
              label="Ad, soyad"
              required
              value={fullName}
              disabled={!manage}
              onChange={(e) => setFullName(e.target.value)}
            />
          </div>
          <TextField
            label="E-poçt"
            mono
            value={email}
            disabled={!manage}
            onChange={(e) => setEmail(e.target.value)}
          />
          <TextField
            label="Telefon"
            mono
            value={phone}
            disabled={!manage}
            onChange={(e) => setPhone(e.target.value)}
          />
          <Select
            label="Vəziyyət"
            value={isActive}
            disabled={!manage}
            hint="Bağlı istifadəçi giriş edə bilmir."
            options={[
              { value: 'true', label: 'Aktiv' },
              { value: 'false', label: 'Bağlı' },
            ]}
            onChange={(e) => setIsActive(e.target.value)}
          />
        </MetaGrid>
        {manage ? (
          <div className="wms-row">
            <Button
              variant="primary"
              loading={saveDetails.isPending}
              disabled={fullName.trim().length === 0}
              onClick={() => saveDetails.mutate()}
            >
              Məlumatları yadda saxla
            </Button>
            {saveDetails.isError ? <ErrorState error={saveDetails.error} /> : null}
          </div>
        ) : null}
      </Card>

      <Card
        title="Rollar"
        actions={
          manage ? (
            <Button variant="primary" loading={saveRoles.isPending} onClick={() => saveRoles.mutate()}>
              Rolları yadda saxla
            </Button>
          ) : null
        }
      >
        {roles.isError ? <ErrorState error={roles.error} /> : null}
        <div className="wms-row">
          {(roles.data?.items ?? []).map((role) => {
            const on = roleIds.includes(role.id);
            return (
              <Button
                key={role.id}
                size="sm"
                variant={on ? 'primary' : 'secondary'}
                aria-pressed={on}
                disabled={!manage}
                title={role.isSystem ? 'Platforma rolu' : undefined}
                onClick={() => setRoleIds((prev) => toggle(prev, role.id))}
              >
                {role.code}
              </Button>
            );
          })}
        </div>
        {roleIds.length === 0 ? (
          <div className="wms-muted wms-small">
            Rolsuz istifadəçi heç bir ekran görmür — sidebar boş qalır.
          </div>
        ) : null}
        {saveRoles.isError ? <ErrorState error={saveRoles.error} /> : null}
      </Card>

      <Card
        title="Lokasiya girişi"
        actions={
          manage ? (
            <Button
              variant="primary"
              loading={saveLocations.isPending}
              disabled={unrestricted && !confirmUnrestricted}
              title={
                unrestricted && !confirmUnrestricted
                  ? 'Boş siyahı bütün lokasiyalara giriş verir — aşağıdaki təsdiqi işarələyin'
                  : undefined
              }
              onClick={() => saveLocations.mutate()}
            >
              Lokasiyaları yadda saxla
            </Button>
          ) : null
        }
      >
        {locations.isError ? <ErrorState error={locations.error} /> : null}

        {unrestricted ? (
          <Alert tone="warning" title="Boş siyahı = bütün lokasiyalar">
            Bu, platformada az göndərməyin çox icazə verdiyi yeganə yerdir. Filial işçisinin
            siyahısını təsadüfən boşaltmaq ona bütün şirkətin qalığını açır.
            <div className="wms-row">
              <Select
                label="Təsdiq"
                value={confirmUnrestricted ? 'true' : 'false'}
                disabled={!manage}
                options={[
                  { value: 'false', label: 'Seçilməyib' },
                  { value: 'true', label: 'Bəli, bütün lokasiyalara giriş verilir' },
                ]}
                onChange={(e) => setConfirmUnrestricted(e.target.value === 'true')}
              />
            </div>
          </Alert>
        ) : (
          <div className="wms-muted wms-small">
            {`${locationIds.length} lokasiya seçilib — istifadəçi yalnız onları görür.`}
          </div>
        )}

        <div className="wms-row">
          {realLocations.map((location) => {
            const on = locationIds.includes(location.id);
            return (
              <Button
                key={location.id}
                size="sm"
                variant={on ? 'primary' : 'secondary'}
                aria-pressed={on}
                disabled={!manage}
                onClick={() => setLocationIds((prev) => toggle(prev, location.id))}
              >
                {location.code}
              </Button>
            );
          })}
        </div>
        {saveLocations.isError ? <ErrorState error={saveLocations.error} /> : null}
      </Card>

      <Card title="Cari rollar">
        <div className="wms-row">
          {doc.roles.map((role) => (
            <Badge key={role.id} tone={role.isSystem ? 'accent' : 'neutral'} title={role.name}>
              {role.code}
            </Badge>
          ))}
          {doc.roles.length === 0 ? <span className="wms-muted">Rol təyin edilməyib.</span> : null}
        </div>
      </Card>
    </DocumentPage>
  );
}
