using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.Inventory.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260921_Inventory_Initial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_balance",
                columns: table => new
                {
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    batch_id = table.Column<long>(type: "bigint", nullable: false, defaultValue: 0L),
                    qty_on_hand = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false, defaultValue: 0m),
                    qty_reserved = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false, defaultValue: 0m),
                    avg_unit_cost = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false, defaultValue: 0m),
                    last_movement_id = table.Column<long>(type: "bigint", nullable: true),
                    updated_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_balance", x => new { x.tenant_id, x.product_id, x.location_id, x.batch_id });
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_batch",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    batch_no = table.Column<string>(type: "varchar(64)", maxLength: 64, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    production_date = table.Column<DateOnly>(type: "date", nullable: true),
                    expiry_date = table.Column<DateOnly>(type: "date", nullable: true),
                    supplier_id = table.Column<uint>(type: "int unsigned", nullable: true),
                    received_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    status = table.Column<string>(type: "enum('ACTIVE','BLOCKED','EXPIRED','QUARANTINE')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    updated_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_batch", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_goods_receipt",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_no = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    doc_date = table.Column<DateOnly>(type: "date", nullable: false),
                    po_id = table.Column<long>(type: "bigint", nullable: true),
                    supplier_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    temperature_c = table.Column<decimal>(type: "decimal(6,2)", precision: 6, scale: 2, nullable: true),
                    quality_status = table.Column<string>(type: "enum('ACCEPTED','PARTIALLY_ACCEPTED','REJECTED')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    packaging_note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    status = table.Column<string>(type: "enum('DRAFT','POSTED','CANCELLED')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    movement_group_id = table.Column<long>(type: "bigint", nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    updated_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_goods_receipt", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_movement_group",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_type = table.Column<string>(type: "enum('RECEIPT','ISSUE','TRANSFER','COUNT_ADJUST','WASTE','SAMPLE','RETURN','OPENING','REVERSAL')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    doc_no = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    doc_date = table.Column<DateOnly>(type: "date", nullable: false),
                    source_doc_type = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    source_doc_id = table.Column<long>(type: "bigint", nullable: true),
                    reason_code_id = table.Column<ushort>(type: "smallint unsigned", nullable: true),
                    note = table.Column<string>(type: "varchar(1000)", maxLength: 1000, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    reverses_group_id = table.Column<long>(type: "bigint", nullable: true),
                    posted_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    posted_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    idempotency_key = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_movement_group", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_setting",
                columns: table => new
                {
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    setting_key = table.Column<string>(type: "varchar(64)", maxLength: 64, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    setting_value = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_setting", x => new { x.tenant_id, x.setting_key });
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_goods_receipt_line",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    receipt_id = table.Column<long>(type: "bigint", nullable: false),
                    line_no = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    po_line_id = table.Column<long>(type: "bigint", nullable: true),
                    ordered_qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    received_qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    rejected_qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    batch_no = table.Column<string>(type: "varchar(64)", maxLength: 64, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    production_date = table.Column<DateOnly>(type: "date", nullable: true),
                    expiry_date = table.Column<DateOnly>(type: "date", nullable: true),
                    unit_price = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    currency = table.Column<string>(type: "char(3)", nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    variance_note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_goods_receipt_line", x => x.id);
                    table.ForeignKey(
                        name: "fk_inv_goods_receipt_line_inv_goods_receipt_receipt_id",
                        column: x => x.receipt_id,
                        principalTable: "inv_goods_receipt",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_movement",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    group_id = table.Column<long>(type: "bigint", nullable: false),
                    line_no = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    batch_id = table.Column<long>(type: "bigint", nullable: true),
                    location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    qty_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    base_uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    entered_qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    entered_uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    conversion_rate = table.Column<decimal>(type: "decimal(18,8)", precision: 18, scale: 8, nullable: false),
                    unit_cost = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    currency = table.Column<string>(type: "char(3)", nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    fx_rate = table.Column<decimal>(type: "decimal(18,8)", precision: 18, scale: 8, nullable: true),
                    posted_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    posted_by = table.Column<uint>(type: "int unsigned", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_movement", x => x.id);
                    table.ForeignKey(
                        name: "fk_inv_movement_inv_movement_group_group_id",
                        column: x => x.group_id,
                        principalTable: "inv_movement_group",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "ix_bal_loc",
                table: "inv_balance",
                columns: new[] { "tenant_id", "location_id", "product_id" });

            migrationBuilder.CreateIndex(
                name: "ix_batch_fefo",
                table: "inv_batch",
                columns: new[] { "tenant_id", "product_id", "status", "expiry_date", "received_at" });

            migrationBuilder.CreateIndex(
                name: "uq_batch",
                table: "inv_batch",
                columns: new[] { "tenant_id", "product_id", "batch_no", "expiry_date" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_gr",
                table: "inv_goods_receipt",
                columns: new[] { "tenant_id", "doc_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_inv_goods_receipt_line_receipt_id",
                table: "inv_goods_receipt_line",
                column: "receipt_id");

            migrationBuilder.CreateIndex(
                name: "uq_grl",
                table: "inv_goods_receipt_line",
                columns: new[] { "tenant_id", "receipt_id", "line_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_inv_movement_group_id",
                table: "inv_movement",
                column: "group_id");

            migrationBuilder.CreateIndex(
                name: "ix_mv_balance",
                table: "inv_movement",
                columns: new[] { "tenant_id", "product_id", "location_id", "batch_id", "id" });

            migrationBuilder.CreateIndex(
                name: "ix_mv_posted",
                table: "inv_movement",
                columns: new[] { "tenant_id", "posted_at" });

            migrationBuilder.CreateIndex(
                name: "uq_mv_line",
                table: "inv_movement",
                columns: new[] { "tenant_id", "group_id", "line_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_mg_src",
                table: "inv_movement_group",
                columns: new[] { "tenant_id", "source_doc_type", "source_doc_id" });

            migrationBuilder.CreateIndex(
                name: "uq_mg_doc",
                table: "inv_movement_group",
                columns: new[] { "tenant_id", "doc_type", "doc_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_mg_idem",
                table: "inv_movement_group",
                columns: new[] { "tenant_id", "idempotency_key" },
                unique: true);

            PartitionMovementLedger(migrationBuilder);
        }

        /// <summary>
        /// Spec §9.4: <c>inv_movement PARTITION BY RANGE (YEAR(posted_at))</c>. EF Core cannot express
        /// partitioning, so it is applied as raw DDL. MySQL/InnoDB imposes two hard preconditions that the
        /// EF-generated table does not satisfy, so they are fixed up first (see backend/README.md §8.3):
        ///
        /// 1. Every unique key (the primary key included) must contain every partitioning column, so
        ///    <c>posted_at</c> is appended to <c>PRIMARY KEY (id)</c> and to <c>uq_mv_line</c>.
        ///    <c>id</c> stays leftmost in the primary key, which InnoDB requires for the AUTO_INCREMENT column.
        /// 2. InnoDB does not support foreign keys on (or to) a partitioned table, so the EF-generated
        ///    <c>group_id</c> foreign key is dropped. Spec §9.4 declares no foreign key on this table either;
        ///    the reference is enforced by the MovementGroup aggregate, which is the only writer.
        /// </summary>
        private static void PartitionMovementLedger(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                "ALTER TABLE `inv_movement` DROP FOREIGN KEY `fk_inv_movement_inv_movement_group_group_id`;");

            // The FK index EF created for the navigation is redundant once the FK is gone: uq_mv_line and
            // ix_mv_balance already cover group_id/product lookups, and a partitioned table pays for every index.
            migrationBuilder.Sql(
                "ALTER TABLE `inv_movement` DROP INDEX `ix_inv_movement_group_id`;");

            migrationBuilder.Sql(
                "ALTER TABLE `inv_movement` DROP INDEX `uq_mv_line`, "
                + "ADD UNIQUE INDEX `uq_mv_line` (`tenant_id`, `group_id`, `line_no`, `posted_at`);");

            migrationBuilder.Sql(
                "ALTER TABLE `inv_movement` DROP PRIMARY KEY, ADD PRIMARY KEY (`id`, `posted_at`);");

            migrationBuilder.Sql(
                """
                ALTER TABLE `inv_movement`
                    PARTITION BY RANGE (YEAR(`posted_at`)) (
                        PARTITION p2026 VALUES LESS THAN (2027),
                        PARTITION p2027 VALUES LESS THAN (2028),
                        PARTITION pmax  VALUES LESS THAN MAXVALUE);
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Undo the raw DDL of PartitionMovementLedger before EF drops the tables. Dropping a partitioned
            // table would work as-is, but removing the partitioning explicitly keeps the migration reversible
            // step by step (and makes `Down` safe if the DropTable list is ever reordered or narrowed).
            migrationBuilder.Sql("ALTER TABLE `inv_movement` REMOVE PARTITIONING;");

            migrationBuilder.DropTable(
                name: "inv_balance");

            migrationBuilder.DropTable(
                name: "inv_batch");

            migrationBuilder.DropTable(
                name: "inv_goods_receipt_line");

            migrationBuilder.DropTable(
                name: "inv_movement");

            migrationBuilder.DropTable(
                name: "inv_setting");

            migrationBuilder.DropTable(
                name: "inv_goods_receipt");

            migrationBuilder.DropTable(
                name: "inv_movement_group");
        }
    }
}
