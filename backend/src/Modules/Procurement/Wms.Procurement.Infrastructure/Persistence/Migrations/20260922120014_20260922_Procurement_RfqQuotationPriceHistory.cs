using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.Procurement.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260922_Procurement_RfqQuotationPriceHistory : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "reject_comment",
                table: "proc_requisition",
                type: "varchar(1000)",
                maxLength: 1000,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "note",
                table: "proc_purchase_order",
                type: "varchar(1000)",
                maxLength: 1000,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "payment_terms",
                table: "proc_purchase_order",
                type: "varchar(200)",
                maxLength: 200,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            // MySQL refuses '' as the default of an ENUM and 0001-01-01 as the default of a DATETIME, and
            // EF only emits those defaults to back-fill existing rows. All seven proc_* tables are empty
            // (the module served one read endpoint until now), so the columns are added without a DEFAULT
            // clause and MySQL's implicit default covers the DDL. Neither default is part of the model — the
            // snapshot configures none of these properties with HasDefaultValue — so dropping them here
            // leaves no pending model change.
            migrationBuilder.AddColumn<string>(
                name: "product_type",
                table: "proc_purchase_order",
                type: "enum('FOOD','NON_FOOD')",
                nullable: false)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<long>(
                name: "quotation_id",
                table: "proc_purchase_order",
                type: "bigint",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "reject_comment",
                table: "proc_purchase_order",
                type: "varchar(1000)",
                maxLength: 1000,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "split_check_warning",
                table: "proc_purchase_order",
                type: "varchar(500)",
                maxLength: 500,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "approver_role_code",
                table: "proc_approval_step",
                type: "varchar(48)",
                maxLength: 48,
                nullable: false,
                defaultValue: "")
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<uint>(
                name: "approver_role_id",
                table: "proc_approval_step",
                type: "int unsigned",
                nullable: false,
                defaultValue: 0u);

            migrationBuilder.AddColumn<string>(
                name: "approver_role_code",
                table: "proc_approval_rule",
                type: "varchar(48)",
                maxLength: 48,
                nullable: false,
                defaultValue: "")
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "created_at",
                table: "proc_approval_rule",
                type: "datetime(3)",
                precision: 3,
                nullable: false);

            migrationBuilder.AddColumn<uint>(
                name: "created_by",
                table: "proc_approval_rule",
                type: "int unsigned",
                nullable: false,
                defaultValue: 0u);

            migrationBuilder.AddColumn<uint>(
                name: "row_version",
                table: "proc_approval_rule",
                type: "int unsigned",
                nullable: false,
                defaultValue: 1u);

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "updated_at",
                table: "proc_approval_rule",
                type: "datetime(3)",
                precision: 3,
                nullable: true);

            migrationBuilder.AddColumn<uint>(
                name: "updated_by",
                table: "proc_approval_rule",
                type: "int unsigned",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "amount_base",
                table: "proc_approval_instance",
                type: "decimal(18,4)",
                precision: 18,
                scale: 4,
                nullable: true);

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "created_at",
                table: "proc_approval_instance",
                type: "datetime(3)",
                precision: 3,
                nullable: false);

            migrationBuilder.AddColumn<uint>(
                name: "created_by",
                table: "proc_approval_instance",
                type: "int unsigned",
                nullable: false,
                defaultValue: 0u);

            migrationBuilder.AddColumn<string>(
                name: "doc_no",
                table: "proc_approval_instance",
                type: "varchar(32)",
                maxLength: 32,
                nullable: false,
                defaultValue: "")
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<uint>(
                name: "requested_by",
                table: "proc_approval_instance",
                type: "int unsigned",
                nullable: false,
                defaultValue: 0u);

            migrationBuilder.AddColumn<uint>(
                name: "row_version",
                table: "proc_approval_instance",
                type: "int unsigned",
                nullable: false,
                defaultValue: 1u);

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "updated_at",
                table: "proc_approval_instance",
                type: "datetime(3)",
                precision: 3,
                nullable: true);

            migrationBuilder.AddColumn<uint>(
                name: "updated_by",
                table: "proc_approval_instance",
                type: "int unsigned",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "proc_price_history",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    supplier_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    po_id = table.Column<long>(type: "bigint", nullable: true),
                    price_date = table.Column<DateOnly>(type: "date", nullable: false),
                    unit_price = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    currency = table.Column<string>(type: "char(3)", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    unit_price_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    prev_price_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    diff_amount = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    diff_pct = table.Column<decimal>(type: "decimal(9,4)", precision: 9, scale: 4, nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_proc_price_history", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "proc_quotation",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    rfq_id = table.Column<long>(type: "bigint", nullable: true),
                    supplier_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    quote_no = table.Column<string>(type: "varchar(64)", maxLength: 64, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    quote_date = table.Column<DateOnly>(type: "date", nullable: false),
                    valid_until = table.Column<DateOnly>(type: "date", nullable: true),
                    currency = table.Column<string>(type: "char(3)", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    delivery_days = table.Column<ushort>(type: "smallint unsigned", nullable: true),
                    payment_terms = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    fx_rate = table.Column<decimal>(type: "decimal(18,8)", precision: 18, scale: 8, nullable: false),
                    total_amount = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    total_amount_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    is_selected = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    selection_note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    updated_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_proc_quotation", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "proc_rfq",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_no = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    doc_date = table.Column<DateOnly>(type: "date", nullable: false),
                    due_date = table.Column<DateOnly>(type: "date", nullable: true),
                    status = table.Column<string>(type: "enum('DRAFT','SENT','CLOSED','CANCELLED')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    note = table.Column<string>(type: "varchar(1000)", maxLength: 1000, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    updated_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_proc_rfq", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "proc_split_check_log",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    supplier_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    window_start = table.Column<DateOnly>(type: "date", nullable: false),
                    window_end = table.Column<DateOnly>(type: "date", nullable: false),
                    cumulative_amount_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    triggered_po_id = table.Column<long>(type: "bigint", nullable: true),
                    triggered_amount_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    steps_for_single = table.Column<byte>(type: "tinyint unsigned", nullable: false),
                    steps_for_cumulative = table.Column<byte>(type: "tinyint unsigned", nullable: false),
                    note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_proc_split_check_log", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "proc_quotation_line",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    quotation_id = table.Column<long>(type: "bigint", nullable: false),
                    line_no = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    rfq_line_id = table.Column<long>(type: "bigint", nullable: true),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    unit_price = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    unit_price_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    line_total = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_proc_quotation_line", x => x.id);
                    table.ForeignKey(
                        name: "fk_proc_quotation_line_proc_quotation_quotation_id",
                        column: x => x.quotation_id,
                        principalTable: "proc_quotation",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "proc_rfq_line",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    rfq_id = table.Column<long>(type: "bigint", nullable: false),
                    line_no = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    requisition_line_id = table.Column<long>(type: "bigint", nullable: true),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_proc_rfq_line", x => x.id);
                    table.ForeignKey(
                        name: "fk_proc_rfq_line_proc_rfq_rfq_id",
                        column: x => x.rfq_id,
                        principalTable: "proc_rfq",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "proc_rfq_supplier",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    rfq_id = table.Column<long>(type: "bigint", nullable: false),
                    supplier_id = table.Column<uint>(type: "int unsigned", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_proc_rfq_supplier", x => x.id);
                    table.ForeignKey(
                        name: "fk_proc_rfq_supplier_proc_rfq_rfq_id",
                        column: x => x.rfq_id,
                        principalTable: "proc_rfq",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "ix_prl_product",
                table: "proc_requisition_line",
                columns: new[] { "tenant_id", "product_id" });

            migrationBuilder.CreateIndex(
                name: "ix_pr_location",
                table: "proc_requisition",
                columns: new[] { "tenant_id", "requester_location_id", "doc_date" });

            migrationBuilder.CreateIndex(
                name: "ix_pr_status",
                table: "proc_requisition",
                columns: new[] { "tenant_id", "status", "doc_date" });

            migrationBuilder.CreateIndex(
                name: "ix_pol_pr_line",
                table: "proc_purchase_order_line",
                columns: new[] { "tenant_id", "requisition_line_id" });

            migrationBuilder.CreateIndex(
                name: "ix_po_status",
                table: "proc_purchase_order",
                columns: new[] { "tenant_id", "status", "doc_date" });

            migrationBuilder.CreateIndex(
                name: "ix_po_supplier",
                table: "proc_purchase_order",
                columns: new[] { "tenant_id", "supplier_id", "doc_date" });

            migrationBuilder.CreateIndex(
                name: "ix_as_pending",
                table: "proc_approval_step",
                columns: new[] { "approver_role_code", "decision" });

            migrationBuilder.CreateIndex(
                name: "ix_ai_status",
                table: "proc_approval_instance",
                columns: new[] { "tenant_id", "status" });

            migrationBuilder.CreateIndex(
                name: "ix_ph",
                table: "proc_price_history",
                columns: new[] { "tenant_id", "product_id", "supplier_id", "price_date" });

            migrationBuilder.CreateIndex(
                name: "ix_ph_date",
                table: "proc_price_history",
                columns: new[] { "tenant_id", "price_date" });

            migrationBuilder.CreateIndex(
                name: "ix_quote",
                table: "proc_quotation",
                columns: new[] { "tenant_id", "rfq_id", "supplier_id" });

            migrationBuilder.CreateIndex(
                name: "ix_quote_supplier",
                table: "proc_quotation",
                columns: new[] { "tenant_id", "supplier_id", "quote_date" });

            migrationBuilder.CreateIndex(
                name: "ix_proc_quotation_line_quotation_id",
                table: "proc_quotation_line",
                column: "quotation_id");

            migrationBuilder.CreateIndex(
                name: "ix_quotel_rfq_line",
                table: "proc_quotation_line",
                columns: new[] { "tenant_id", "rfq_line_id" });

            migrationBuilder.CreateIndex(
                name: "uq_quotel",
                table: "proc_quotation_line",
                columns: new[] { "tenant_id", "quotation_id", "line_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_rfq_status",
                table: "proc_rfq",
                columns: new[] { "tenant_id", "status", "doc_date" });

            migrationBuilder.CreateIndex(
                name: "uq_rfq",
                table: "proc_rfq",
                columns: new[] { "tenant_id", "doc_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_proc_rfq_line_rfq_id",
                table: "proc_rfq_line",
                column: "rfq_id");

            migrationBuilder.CreateIndex(
                name: "ix_rfql_pr_line",
                table: "proc_rfq_line",
                columns: new[] { "tenant_id", "requisition_line_id" });

            migrationBuilder.CreateIndex(
                name: "uq_rfql",
                table: "proc_rfq_line",
                columns: new[] { "tenant_id", "rfq_id", "line_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_proc_rfq_supplier_rfq_id",
                table: "proc_rfq_supplier",
                column: "rfq_id");

            migrationBuilder.CreateIndex(
                name: "uq_rfqs",
                table: "proc_rfq_supplier",
                columns: new[] { "tenant_id", "rfq_id", "supplier_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_split",
                table: "proc_split_check_log",
                columns: new[] { "tenant_id", "supplier_id", "window_start" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "proc_price_history");

            migrationBuilder.DropTable(
                name: "proc_quotation_line");

            migrationBuilder.DropTable(
                name: "proc_rfq_line");

            migrationBuilder.DropTable(
                name: "proc_rfq_supplier");

            migrationBuilder.DropTable(
                name: "proc_split_check_log");

            migrationBuilder.DropTable(
                name: "proc_quotation");

            migrationBuilder.DropTable(
                name: "proc_rfq");

            migrationBuilder.DropIndex(
                name: "ix_prl_product",
                table: "proc_requisition_line");

            migrationBuilder.DropIndex(
                name: "ix_pr_location",
                table: "proc_requisition");

            migrationBuilder.DropIndex(
                name: "ix_pr_status",
                table: "proc_requisition");

            migrationBuilder.DropIndex(
                name: "ix_pol_pr_line",
                table: "proc_purchase_order_line");

            migrationBuilder.DropIndex(
                name: "ix_po_status",
                table: "proc_purchase_order");

            migrationBuilder.DropIndex(
                name: "ix_po_supplier",
                table: "proc_purchase_order");

            migrationBuilder.DropIndex(
                name: "ix_as_pending",
                table: "proc_approval_step");

            migrationBuilder.DropIndex(
                name: "ix_ai_status",
                table: "proc_approval_instance");

            migrationBuilder.DropColumn(
                name: "reject_comment",
                table: "proc_requisition");

            migrationBuilder.DropColumn(
                name: "note",
                table: "proc_purchase_order");

            migrationBuilder.DropColumn(
                name: "payment_terms",
                table: "proc_purchase_order");

            migrationBuilder.DropColumn(
                name: "product_type",
                table: "proc_purchase_order");

            migrationBuilder.DropColumn(
                name: "quotation_id",
                table: "proc_purchase_order");

            migrationBuilder.DropColumn(
                name: "reject_comment",
                table: "proc_purchase_order");

            migrationBuilder.DropColumn(
                name: "split_check_warning",
                table: "proc_purchase_order");

            migrationBuilder.DropColumn(
                name: "approver_role_code",
                table: "proc_approval_step");

            migrationBuilder.DropColumn(
                name: "approver_role_id",
                table: "proc_approval_step");

            migrationBuilder.DropColumn(
                name: "approver_role_code",
                table: "proc_approval_rule");

            migrationBuilder.DropColumn(
                name: "created_at",
                table: "proc_approval_rule");

            migrationBuilder.DropColumn(
                name: "created_by",
                table: "proc_approval_rule");

            migrationBuilder.DropColumn(
                name: "row_version",
                table: "proc_approval_rule");

            migrationBuilder.DropColumn(
                name: "updated_at",
                table: "proc_approval_rule");

            migrationBuilder.DropColumn(
                name: "updated_by",
                table: "proc_approval_rule");

            migrationBuilder.DropColumn(
                name: "amount_base",
                table: "proc_approval_instance");

            migrationBuilder.DropColumn(
                name: "created_at",
                table: "proc_approval_instance");

            migrationBuilder.DropColumn(
                name: "created_by",
                table: "proc_approval_instance");

            migrationBuilder.DropColumn(
                name: "doc_no",
                table: "proc_approval_instance");

            migrationBuilder.DropColumn(
                name: "requested_by",
                table: "proc_approval_instance");

            migrationBuilder.DropColumn(
                name: "row_version",
                table: "proc_approval_instance");

            migrationBuilder.DropColumn(
                name: "updated_at",
                table: "proc_approval_instance");

            migrationBuilder.DropColumn(
                name: "updated_by",
                table: "proc_approval_instance");
        }
    }
}
