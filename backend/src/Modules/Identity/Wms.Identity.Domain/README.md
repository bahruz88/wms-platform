# Wms.Identity.Domain

Şema prefiksi: `iam_`. Başqa moduldan asılılığı yoxdur (SPEC §5).

## Sahib olduğu cədvəllər (SPEC §7)

| Entity | Cədvəl | Qeyd |
|---|---|---|
| `Tenant` | `iam_tenant` | tenant kartı, `default_currency`, `timezone`, `locale`; `tenant_id` daşımır (kök obyektdir) |
| `User` | `iam_user` | Keycloak `sub` → `external_id`, `uq_user_username`, `uq_user_external` |
| `Role` | `iam_role` | `ADMIN`, `PROCUREMENT_OFFICER`, `PROCUREMENT_MANAGER`, `WAREHOUSE_KEEPER`, `BRANCH_USER`, `AUDITOR` |
| `Permission` | `iam_permission` | qlobal (tenant-siz) icazə kataloqu, `uq_perm_code` |
| `RolePermission` | `iam_role_permission` | rol ↔ icazə |
| `UserRole` | `iam_user_role` | istifadəçi ↔ rol |
| `UserLocation` | `iam_user_location` | filial məhdudiyyəti (SPEC §16) |
| `Delegation` | `iam_delegation` | approval delegasiyası (SPEC §7) |

## Kritik icazələr (SPEC §7.1)

`master.product.view_cost` (anbardarda **olmamalıdır**), `inv.adjustment.approve`, `inv.waste.approve`,
`proc.po.approve`, `inv.movement.reverse`.
