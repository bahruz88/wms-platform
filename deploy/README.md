# Deploy — Docker Compose, on-prem və Kubernetes

Bu qovluq platformanın bütün infrastruktur/deployment artefaktlarını saxlayır.
Adlar, portlar və konfiqurasiya açarları `docs/CONVENTIONS.md`-dəki kimidir; ziddiyyət
olarsa SPEC (§3, §16, §18) üstündür.

```
deploy/
├── docker-compose.yml           dev stack (profillər: infra | app | migrate)
├── docker-compose.onprem.yml    on-prem: tək wms-api + infra (SPEC §18.2)
├── .env.example                 bütün port/parol dəyişənləri (→ .env, git-ignored)
├── docker/
│   ├── backend.Dockerfile       bütün .NET host-lar üçün tək Dockerfile (HOST_PROJECT arg)
│   ├── web.Dockerfile           Flutter web → nginx
│   └── nginx.conf               SPA fallback, gzip, cache, /api → gateway proxy
├── mysql/
│   ├── conf.d/wms.cnf           utf8mb4_0900_ai_ci, UTC, strict sql_mode, ROW binlog
│   ├── init/01-users.sql        db `wms`, istifadəçilər wms_app / wms_migrator / wms_reporting
│   ├── init/02-ledger-grants.sql  wms_ops.apply_ledger_grants() prosedura (ledger qoruması)
│   └── post-migrate/ledger-grants.sql  hər miqrasiyadan sonra CALL
├── rabbitmq/                    definitions.json (wms.events + queue-lar), rabbitmq.conf
├── keycloak/realm-wms.json      realm `wms`: client-lər, rollar, tenant_id claim, dev istifadəçilər
├── onprem/                      backup.sh, render-realm.sh, mysql-init/01-users.sh
└── k8s/                         kustomize base + overlays/{dev,prod}
scripts/                         dev-up / dev-down / dev-logs / db-migrate / db-ledger-grants / keycloak-token
```

---

## 1. Dev quick start

Tələblər: Docker 24+ (Compose v2.24+), `bash`, `curl`; `jq` tövsiyə olunur.

```bash
cp deploy/.env.example deploy/.env      # lazım olsa portları dəyiş (aşağıya bax)
scripts/dev-up.sh                       # infra: mysql, redis, rabbitmq, minio, keycloak, seq
scripts/db-migrate.sh                   # EF miqrasiyaları (migrator konteyneri) + ledger grant-ları
scripts/dev-up.sh --app                 # backend + web image-larını build edib qaldırır
scripts/keycloak-token.sh keeper --decode
scripts/dev-logs.sh keycloak            # loglar
scripts/dev-down.sh [-v]                # dayandır; -v volume-ları da silir
```

`dev-up.sh` əvvəlcə host portlarının boş olduğunu yoxlayır, sonra `docker compose --profile infra up -d`
edir, bütün servislərin `healthy` olmasını gözləyir və URL/parol cədvəlini çap edir.

### Port override mexanizmi (`deploy/.env`)

Compose faylındakı **bütün** host portları `${DƏYIŞƏN:-default}` şəklindədir, ona görə YAML-a
toxunmadan `deploy/.env` ilə dəyişdirilir. Konteyner daxilindəki portlar (8080, 3306, 6379 …)
heç vaxt dəyişmir — yalnız host tərəfi sürüşür, yəni `docs/CONVENTIONS.md` pozulmur.

```bash
# deploy/.env
GATEWAY_PORT=5001
API_BASE_URL=http://localhost:5001              # Flutter build-inə keçir, gateway portu ilə eyni olmalıdır
KEYCLOAK_PORT=8180
KEYCLOAK_ISSUER=http://localhost:8180/realms/wms  # KC_HOSTNAME buradan qurulur, token `iss` ilə eyni olmalıdır
MYSQL_PORT=3308
```

Portu dəyişəndə **cütlüyü də yeniləyin**: `GATEWAY_PORT` ↔ `API_BASE_URL`,
`KEYCLOAK_PORT` ↔ `KEYCLOAK_ISSUER`. Əks halda brauzer `iss` uyğunsuzluğuna görə 401 alır.
`scripts/dev-up.sh` start-dan əvvəl hər portu yoxlayır və tutulubsa kimin tutduğunu göstərir.

> **Bu maşında (macOS) 3 port tutulu idi və `.env`-də köçürülüb** — default dəyərlər
> `.env.example`-də olduğu kimi qalır:
>
> | Servis | CONVENTIONS default | Bu maşında | Səbəb |
> |---|---|---|---|
> | Gateway | 5000 | **5001** | macOS AirPlay Receiver (ControlCenter) |
> | Keycloak | 8080 | **8180** | başqa layihənin `miis-app` konteyneri |
> | MySQL | 3306 | **3308** | hostda işləyən XAMPP `mysqld` (root) |
>
> macOS-da 5000/7000 AirPlay-ə məxsusdur (System Settings → General → AirDrop & Handoff);
> onu söndürsəniz 5000 azad olur. Root-a məxsus dinləyiciləri `lsof` (root olmadan) göstərmir,
> ona görə `dev-up.sh` əlavə olaraq `netstat` və birbaşa TCP probe işlədir.

### Servislər (dev)

Aşağıdakı cədvəldə **default port / bu maşındakı port** göstərilib (fərq varsa).

| Servis | URL (host) | Giriş | Konteyner daxilində |
|---|---|---|---|
| Gateway (YARP) | http://localhost:5000 → **http://localhost:5001** | Bearer token | `gateway:8080` |
| wms-identity / masterdata / inventory / procurement / reporting | :5081 / :5082 / :5083 / :5084 / :5085 | Bearer token | `wms-<modul>:8080` |
| wms-worker (Hangfire) | http://localhost:5086/hangfire | — | `wms-worker:8080` |
| Web (nginx) | http://localhost:3000 | Keycloak login | `web:8080` |
| MySQL 8.4 | localhost:3306 → **localhost:3308**, db `wms` | `root`/`wms_root`, `wms_app`/`wms_app`, `wms_migrator`/`wms_migrator`, `wms_reporting`/`wms_reporting` | `mysql:3306` |
| Redis 7 | localhost:6379 | — | `redis:6379` |
| RabbitMQ 4 | amqp://localhost:5672, UI http://localhost:15672 | `wms`/`wms` | `rabbitmq:5672` |
| MinIO | http://localhost:9000, konsol http://localhost:9001 | `minioadmin`/`minioadmin`, bucket `wms-attachments` | `minio:9000` |
| Keycloak 26 | http://localhost:8080 → **http://localhost:8180** (admin konsol), realm `wms` | `admin`/`admin` | `keycloak:8080` |
| Seq | http://localhost:5341 | auth söndürülüb | `seq:5341` |

Qalın port = bu maşındakı `deploy/.env` override-i; digər maşınlarda default işləyir.
Nümunələr: `mysql -h 127.0.0.1 -P 3308 -uwms_app -pwms_app wms` ·
`curl http://localhost:8180/realms/wms/.well-known/openid-configuration`

Keycloak dev istifadəçiləri (parol = username, hamısı `tenant_id=1`):
`admin` (ADMIN), `procurement` (PROCUREMENT_OFFICER), `manager` (PROCUREMENT_MANAGER),
`keeper` (WAREHOUSE_KEEPER), `branch1` (BRANCH_USER), `auditor` (AUDITOR).

### Profillər

| Profil | Servislər | Nə vaxt |
|---|---|---|
| `infra` | mysql, redis, rabbitmq (+`rabbitmq-init`), minio (+`minio-init`), keycloak, seq | həmişə (`dev-up.sh`) |
| `app` | gateway, wms-identity, wms-masterdata (`masterdata,identity,documents`), wms-inventory (`inventory,consumption`), wms-procurement, wms-reporting, wms-worker (`Modules=*`, `Jobs__Enabled=true`), web | backend-i konteynerdə işlətmək üçün (`dev-up.sh --app`) |
| `migrate` | migrator (run-once) | `db-migrate.sh` |

> **`app` və `migrate` profilləri həmişə `infra` ilə birlikdə verilir**
> (`--profile infra --profile app`): bu servislər infra servislərinə `depends_on` ilə bağlıdır,
> tək `--profile app` isə Compose-da `depends on undefined service` xətası verir.
> `scripts/dev-up.sh --app`, `scripts/db-migrate.sh` və `dev-down.sh` bunu avtomatik edir.

Backend-i IDE-dən işlədəndə yalnız `infra` qaldırılır; `appsettings.Development.json`-da host adları
`localhost` olur (məs. `Server=localhost;Port=3306;...`, `Keycloak__Authority=http://localhost:8080/realms/wms`).

`app` profilindəki servislər `ModuleTransport=Http` ilə işləyir (modullar ayrı konteynerlərdə);
`wms-worker` `Modules=*` + `InProcess`. Bütün env açarları `docker-compose.yml`-də `x-backend-env`
anchor-undadır və CONVENTIONS ilə eynidir.

> **`appsettings.Development.json` konteynerdə də yüklənir.** `ASPNETCORE_ENVIRONMENT=Development`
> olduğu üçün orada yazılmış `localhost:508x` ünvanları compose-dan **env var ilə üzərinə yazılır**:
> `ModuleEndpoints__{Identity,MasterData,Inventory,Procurement,Documents}` (modullararası HTTP) və
> `ReverseProxy__Clusters__<cluster>__Destinations__d1__Address` (gateway YARP). Bu override-lar
> olmadan modullararası çağırışlar və bütün gateway route-ları 502 verir.
>
> **Env var adlarında `-` işlənə bilməz.** `backend.Dockerfile`-ın entrypoint-i `/bin/sh` (dash)
> skriptidir; dash uşaq prosesin mühitini öz dəyişən cədvəlindən qurur və adı düzgün shell
> identifikatoru olmayan dəyişənləri **səssizcə atır** (`docker inspect` onları göstərsə də .NET-ə
> çatmır). Buna görə YARP cluster id-ləri `identity`, `masterdata`, … adlanır — `wms-identity` deyil.

### Keycloak qeydləri

* **Issuer.** Dev-də `KC_HOSTNAME=http://localhost:${KEYCLOAK_PORT}` və
  `KC_HOSTNAME_BACKCHANNEL_DYNAMIC=true` verilib: brauzer də, konteynerlər də eyni
  `iss=http://localhost:8080/realms/wms` görür, API isə metadata/JWKS-i `http://keycloak:8080` üzərindən
  alır. Backend-də issuer üçün xüsusi hal lazım deyil.
* **Token claim-ləri.** `tenant_id` (user attribute → claim, access+ID token), `aud` = `wms-api`
  (audience mapper), `realm_access.roles`, `preferred_username`. Access token 15 dəq, SSO idle 8 saat (SPEC §16).
* **Direct access grants** `wms-web` client-ində **yalnız dev üçün** açıqdır (`scripts/keycloak-token.sh`).
  On-prem üçün `deploy/onprem/render-realm.sh` bunu söndürür və dev istifadəçilərini silir.
* **Realm faylını dəyişdikdə** `--import-realm` mövcud realm-ı üzərinə yazmır: `scripts/dev-down.sh -v`
  (və ya `docker volume rm wms_keycloak_data`) → `dev-up.sh`.
* Mobil emulator: `KEYCLOAK_ISSUER=http://10.0.2.2:8080/realms/wms` istifadə etsəniz discovery sənədindəki
  issuer `localhost` olacaq — AppAuth üçün problem deyil, amma strict issuer yoxlayan kitabxanalarda nəzərə alın.

### MySQL ledger qoruması (SPEC §9.4, §16)

`inv_movement` və `common_audit_log` üçün `wms_app` istifadəçisinə **yalnız SELECT, INSERT** verilir.
MySQL-də mənfi (deny) grant olmadığı üçün əks məntiq tətbiq olunur:

1. `01-users.sql`: `GRANT SELECT, INSERT ON wms.* TO wms_app` (bazadan bütöv).
2. `02-ledger-grants.sql`: `wms_ops.apply_ledger_grants()` proseduru — `wms` sxemindəki ledger olmayan
   **hər cədvələ** ayrıca `GRANT UPDATE, DELETE`, sonra invariantı yoxlayır (ledger-də UPDATE/DELETE varsa SIGNAL).
3. Cədvəllər init anında mövcud olmadığından prosedur **hər miqrasiyadan sonra** çağırılır:
   `scripts/db-ledger-grants.sh` (`db-migrate.sh` bunu avtomatik edir), k8s-də `job-migrator.yaml`-ın
   `ledger-grants` konteyneri.

Nəticə: yeni cədvəl əlavə edən miqrasiyadan sonra grant-lar yenilənməsə, API həmin cədvəldə UPDATE/DELETE
edə bilməz — bu bilərəkdən "fail-closed" davranışdır. Hangfire sxemi (`hangfire_*`, 12 cədvəl) də
`wms_migrator` ilə yaradılır: `Wms.Host.Migrator` EF kontekstlərindən sonra
`WmsJobsExtensions.EnsureJobStorageSchema(...)` çağırır, host-larda isə
`MySqlStorageOptions.PrepareSchemaIfNecessary=false`-dur (`wms_app`-in CREATE hüququ yoxdur, SPEC §18.3).
`db-ledger-grants.sh` çağırışdan sonra `hangfire_*` cədvəllərinə də UPDATE/DELETE verir — `db-migrate.sh`
bunu avtomatik doğru sıra ilə edir.

---

## 2. Image-lar

| Image | Dockerfile | Build arg-ları |
|---|---|---|
| `wms/api` | `docker/backend.Dockerfile` | `HOST_PROJECT=Wms.Host.Api` (default) |
| `wms/gateway` | `docker/backend.Dockerfile` | `HOST_PROJECT=Wms.Gateway` |
| `wms/migrator` | `docker/backend.Dockerfile` | `HOST_PROJECT=Wms.Host.Migrator` |
| `wms/web` | `docker/web.Dockerfile` | `API_BASE_URL`, `KEYCLOAK_ISSUER`, `KEYCLOAK_CLIENT_ID` (`--dart-define`) |

```bash
# əl ilə build (multi-arch, CI üçün)
docker buildx build --platform linux/amd64,linux/arm64 \
  -f deploy/docker/backend.Dockerfile --build-arg HOST_PROJECT=Wms.Host.Api -t ghcr.io/org/wms-api:1.0.0 --push backend
docker buildx build --platform linux/amd64,linux/arm64 \
  -f deploy/docker/web.Dockerfile --build-context deploy=deploy/docker \
  --build-arg API_BASE_URL=/api --build-arg KEYCLOAK_ISSUER=https://auth.example.com/realms/wms \
  -t ghcr.io/org/wms-web:1.0.0 --push frontend
```

* Backend: SDK mərhələsi həmişə host arxitekturasında işləyir və `-a $TARGETARCH` ilə cross-compile edir;
  restore layer-i yalnız `*.csproj/*.props` dəyişəndə yenilənir; runtime non-root (`app`, uid 1654), port 8080,
  entrypoint `dotnet /app/$HOST_PROJECT.dll "$@"` (`--Modules=...` arqumentləri ötürülür).
* Web: `ghcr.io/cirruslabs/flutter:stable` → `flutter pub get` (workspace kökü) → `apps/wms_web`-də
  `flutter build web --release`; nginx `nginxinc/nginx-unprivileged:stable-alpine` (`nginx:alpine`-ın
  non-root variantı, port 8080). `nginx.conf` `deploy` adlı əlavə build context-dən gəlir.
* `.dockerignore`: `backend/.dockerignore` (bin/obj/.vs/TestResults), `frontend/.dockerignore`
  (build/.dart_tool/android/ios/.idea).

---

## 3. On-prem (SPEC §18.2)

Tək host, `docker-compose.onprem.yml`: `wms-api` (`Modules=*`, `Jobs__Enabled=true`, `InProcess`) → `:5000`,
web (nginx `/api` → `wms-api`) → `:3000`, MySQL, Redis (parollu), RabbitMQ, MinIO, Keycloak (**prod rejim**, MySQL
üzərində). Gateway yoxdur.

```bash
cd deploy
cp .env.example .env
#  -> BÜTÜN parolları dəyişin; KEYCLOAK_HOSTNAME=https://auth.example.com ; WEB_PUBLIC_URL=https://wms.example.com
./onprem/render-realm.sh                          # onprem/realm-wms.rendered.json (dev user-lər silinir, redirect URI-lər real)
#  -> .env: KEYCLOAK_REALM_FILE=./onprem/realm-wms.rendered.json
docker compose -f docker-compose.onprem.yml up -d --build
docker compose -f docker-compose.onprem.yml --profile migrate run --rm migrator
../scripts/db-ledger-grants.sh -f docker-compose.onprem.yml
```

* TLS müştərinin reverse proxy-sində (nginx/Caddy/Traefik) bitir: `wms.example.com → web:3000`,
  `auth.example.com → keycloak:8080` (`KC_PROXY_HEADERS=xforwarded`, `KC_HTTP_ENABLED=true`).
  Sadə LAN quraşdırmasında `KEYCLOAK_HOSTNAME=http://192.168.x.y:8080` da işləyir (realm `sslRequired=external`:
  özəl IP-lər üçün HTTPS tələb olunmur).
* Restart siyasəti `unless-stopped`, resurs limitləri `deploy.resources.limits`, loglar `json-file` (50 MB × 5).
* MySQL/RabbitMQ/MinIO idarə portları yalnız `127.0.0.1`-ə bağlanır (SSH tunel ilə giriş).
* Keycloak `start` ilk dəfə ~1 dəq build edir; `KC_HEALTH_ENABLED` ilə health 9000-ci daxili portdadır.

---

## 4. Kubernetes (cloud, SPEC §18.1)

```
k8s/base/         namespace, configmap-wms, secret-wms.example, job-migrator, deployment/service × 8, ingress
k8s/overlays/dev  1 replika, tag `dev`, wms-dev.example.com, ASPNETCORE_ENVIRONMENT=Development
k8s/overlays/prod SPEC §18.1 replikaları (gateway 2, identity 2, masterdata 2, inventory 3, procurement 2, worker 1, reporting 2), PDB-lər
```

```bash
kubectl kustomize deploy/k8s/overlays/dev | less          # yoxla
kubectl apply -k deploy/k8s/overlays/dev
# və ya konteynerlə:
docker run --rm -v "$PWD/deploy/k8s:/k8s" registry.k8s.io/kustomize/kustomize:v5.4.3 build /k8s/overlays/prod
```

**Infra idarə olunan/xarici sayılır** (cloud MySQL 8.4, Redis, RabbitMQ operator/managed, MinIO və ya S3,
Keycloak, Seq). Ünvanlar `configmap-wms.yaml`-da, sirlər `secret-wms.example.yaml`-da:

| Açar | Harada | Nümunə |
|---|---|---|
| `ConnectionStrings__Wms`, `ConnectionStrings__WmsMigrator` | Secret `wms-secrets` | `Server=mysql.wms-infra.svc;Port=3306;Database=wms;User=wms_app;Password=...;` |
| `Redis__ConnectionString` | ConfigMap | `redis.wms-infra.svc.cluster.local:6379` |
| `RabbitMq__Host` / `__Exchange` · `__User` / `__Password` | ConfigMap · Secret | `rabbitmq.wms-infra.svc.cluster.local` / `wms.events` |
| `Minio__Endpoint` / `__Bucket` · `__AccessKey` / `__SecretKey` | ConfigMap · Secret | `minio.wms-infra.svc.cluster.local:9000` / `wms-attachments` |
| `Keycloak__Authority`, `Keycloak__Audience` | ConfigMap | `https://auth.example.com/realms/wms`, `wms-api` |
| `Seq__Url`, `Otel__Endpoint` | ConfigMap | `http://seq.wms-infra.svc.cluster.local:5341` |
| `MYSQL_HOST/PORT/ADMIN_USER/PWD` | Secret `wms-db-admin` (yalnız migrator job) | root/DBA hesabı |

DBA idarə olunan MySQL-də bir dəfə `deploy/mysql/init/01-users.sql` (parolları dəyişərək) və
`02-ledger-grants.sql` tətbiq edir; MySQL parametrləri `conf.d/wms.cnf`-ə uyğun olmalıdır
(`utf8mb4_0900_ai_ci`, UTC, ROW binlog).

**Miqrasiya sırası** (SPEC §18.3 — startup-da avtomatik miqrasiya qadağandır):

```bash
kubectl -n wms delete job wms-migrator --ignore-not-found
kubectl kustomize deploy/k8s/overlays/prod | kubectl apply -f - -l app.kubernetes.io/component=migration
kubectl -n wms wait --for=condition=complete --timeout=15m job/wms-migrator
kubectl apply -k deploy/k8s/overlays/prod        # sonra rollout
```

Job iki addımdır: initContainer `migrate` (Wms.Host.Migrator, `wms_migrator`) → konteyner `ledger-grants`
(`CALL wms_ops.apply_ledger_grants()`). Argo CD-də `PreSync` hook annotasiyaları var. Köhnə pod-lar miqrasiya
zamanı işlədiyi üçün miqrasiyalar geriyə uyğun (expand/contract) olmalıdır.

Deployment-lər: `/health/live` (liveness/startup), `/health/ready` (readiness), non-root, read-only rootfs,
pod anti-affinity; `wms-worker` `Recreate` strategiyası ilə tək replika. Ingress: `/api` → `wms-gateway`,
`/` → `wms-web` (ingress-nginx + cert-manager annotasiyaları).

---

## 5. Backup / DR (SPEC §18.4)

Hədəf: **RPO ≤ 15 dəq, RTO ≤ 4 saat**.

| Komponent | Mexanizm | Tezlik |
|---|---|---|
| MySQL tam | `mysqldump --single-transaction --all-databases --source-data=2` (`onprem/backup.sh full`) | gündəlik 01:30 |
| MySQL binlog | ROW binlog (`wms.cnf`, 7 gün saxlanır); `backup.sh binlog` → `FLUSH BINARY LOGS` + yeni faylların arxivi | hər 15 dəq (RPO) |
| MinIO | bucket-də versiyalaşdırma aktiv (`minio-init`), `mc mirror` ilə off-box kopya (`backup.sh minio`) | gündəlik |
| Keycloak | on-prem-də MySQL-dədir (tam dump-a daxil); realm konfiqurasiyası git-dədir | — |
| RabbitMQ / Redis | keçici (outbox MySQL-dədir, cache yenidən qurulur) — backup tələb olunmur | — |

```cron
*/15 * * * *  /opt/wms/deploy/onprem/backup.sh binlog >> /var/log/wms-backup.log 2>&1
30 1  * * *   /opt/wms/deploy/onprem/backup.sh full   >> /var/log/wms-backup.log 2>&1
```
`WMS_BACKUP_DIR` (default `/var/backups/wms`) hökmən ikinci maşına/obyekt anbarına köçürülməlidir (rsync/rclone).

**Bərpa (PITR), rüblük məşq edilir:**
1. Yeni `mysql` konteyneri (boş volume) → `gunzip -c wms-full-*.sql.gz | mysql -uroot -p`.
2. Dump-dakı `-- CHANGE MASTER ... / SET @@GLOBAL.GTID_PURGED` mövqeyindən sonrakı binlog-lar:
   `mysqlbinlog --stop-datetime="YYYY-MM-DD HH:MM:SS" binlog.00000N ... | mysql -uroot -p`.
3. `scripts/db-ledger-grants.sh` (grant-lar dump-dadır, amma yoxlayın).
4. MinIO: `mc mirror /backup/wms-attachments src/wms-attachments` (versiyalar itmir, çatışmayan obyektlər qayıdır).
5. Tətbiqi qaldırın, `BalanceReconciliation`/`DoubleEntryCheck` job-larını (SPEC §15) əl ilə işə salın.
Bərpa müddəti ölçülüb protokollaşdırılır (RTO ≤ 4 saat).

Kubernetes-də bu, idarə olunan DB-nin snapshot + PITR xüsusiyyəti (RPO 5–15 dəq) və S3 versiyalaşdırma/replikasiya ilə
əvəz olunur; eyni bərpa məşqi rüblük təkrarlanır.

---

## 6. Sirlərin rotasiyası

Bütün sirlər env dəyişənlərindədir (`appsettings.json`-da yox, SPEC §16). Rotasiya addımları:

| Sirr | Rotasiya |
|---|---|
| MySQL parolları (`wms_app`, `wms_migrator`, `wms_reporting`, `keycloak`) | `ALTER USER 'wms_app'@'%' IDENTIFIED BY '<yeni>'` → `.env`-də (`MYSQL_APP_PASSWORD` və s.) / k8s Secret-də yenilə → `docker compose up -d` / `kubectl rollout restart deploy -n wms`. Köhnə sessiyalar bağlanmır; `KILL` lazım olsa DBA. |
| Redis (`REDIS_PASSWORD`) | `redis-cli CONFIG SET requirepass <yeni>` + `.env` → api restart (ardıcıllıq: əvvəl Redis, sonra api). |
| RabbitMQ (`RABBITMQ_PASSWORD`) | `rabbitmqctl change_password wms <yeni>` → `.env` → api restart. |
| MinIO root (`MINIO_ROOT_*`) | Tövsiyə: root açarını tətbiqdə istifadə etmə, `mc admin user add` ilə ayrıca `wms-api` istifadəçisi + `readwrite` policy yarat və onu rotasiya et. |
| Keycloak admin | Admin konsol → master realm → Users → parol; `.env`-də `KEYCLOAK_ADMIN_PASSWORD` yalnız ilk bootstrap üçündür. |
| Keycloak realm açarları (RS256) | Realm settings → Keys → yeni provider (priority yüksək), köhnəsini "passive" et, 15 dəq (access token ömrü) + refresh dövrü keçəndən sonra sil. API JWKS-i avtomatik yeniləyir. |
| k8s Secret-lər | `wms-secrets`/`wms-db-admin`-i ESO/SealedSecrets ilə idarə et; dəyişiklikdən sonra `kubectl rollout restart` (envFrom yenidən oxunmur). |
| MySQL root | Yalnız backup/ledger-grant skriptləri istifadə edir: `ALTER USER 'root'@'%'` → `.env` (`MYSQL_ROOT_PASSWORD`) → `docker compose up -d mysql` (healthcheck env-dən oxuyur). |

Dev `.env`-dəki dəyərlər ictimai dev parollarıdır; on-prem/prod üçün `.env.example`-dakı bütün `change_me`/dev
dəyərlər dəyişdirilməlidir (`docker-compose.onprem.yml` boş parolla qalxmır — `${VAR:?}` yoxlaması).

---

## 7. Tez-tez rast gəlinən problemlər

| Simptom | Səbəb / həll |
|---|---|
| `dev-up.sh`: port busy | `.env`-də portu dəyiş (bax §1). macOS-da 5000/7000 = AirPlay; 3306 çox vaxt lokal MySQL/XAMPP/Homebrew-dur (`MYSQL_PORT=3308`). Root prosesləri `lsof` göstərmir — skript `netstat`/connect-probe ilə yoxlayır. |
| Keycloak `AccessDeniedException ... /opt/keycloak/data` | Volume köhnə yolda yaradılıb → `docker volume rm wms_keycloak_data`. |
| Keycloak realm dəyişikliyi görünmür | `--import-realm` mövcud realm-ı üzərinə yazmır → `dev-down.sh -v`. |
| Keycloak import-da crash loop, `UPGroup`/`UPAttribute` xətası | `kc.user.profile.config` sxemi Keycloak 26-da ciddidir: qrup yalnız `name`, `displayHeader`, `displayDescription`, `annotations` qəbul edir (`displayName` YOXDUR), atribut isə `name`, `displayName`, `validations`, `permissions`, `required`, `multivalued`, `annotations`. Loglarda `scripts/dev-logs.sh keycloak` ilə dəqiq sahə adı görünür. |
| API `401` — issuer uyğunsuzluğu | `KC_HOSTNAME` ilə `KEYCLOAK_ISSUER`/`.env` portu eyni olmalıdır. |
| `wms_app` UPDATE-də `command denied` | Miqrasiyadan sonra `scripts/db-ledger-grants.sh` işlədilməyib. |
| `rabbitmq-init` / `minio-init` `exited (1)` | `scripts/dev-logs.sh rabbitmq-init` — adətən parol `.env` ilə uyğunsuzdur. |
| MinIO image tapılmır (`minio/minio`) | Docker Hub reposu 2025-də bağlanıb; `quay.io/minio/minio` istifadə olunur. |
