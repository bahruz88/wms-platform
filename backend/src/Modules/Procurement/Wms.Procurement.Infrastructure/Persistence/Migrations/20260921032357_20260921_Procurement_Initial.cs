using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.Procurement.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260921_Procurement_Initial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "proc_approval_instance",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_type = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    doc_id = table.Column<long>(type: "bigint", nullable: false),
                    current_step = table.Column<byte>(type: "tinyint unsigned", nullable: false),
                    status = table.Column<string>(type: "enum('PENDING','APPROVED','REJECTED','CANCELLED')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_proc_approval_instance", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "proc_approval_rule",
                columns: table => new
                {
                    id = table.Column<uint>(type: "int unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_type = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    product_type = table.Column<string>(type: "enum('FOOD','NON_FOOD','ANY')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    min_amount_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    max_amount_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    step_no = table.Column<byte>(type: "tinyint unsigned", nullable: false),
                    approver_role_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    is_active = table.Column<bool>(type: "tinyint(1)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_proc_approval_rule", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "proc_purchase_order",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_no = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    doc_date = table.Column<DateOnly>(type: "date", nullable: false),
                    supplier_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    currency = table.Column<string>(type: "char(3)", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    fx_rate = table.Column<decimal>(type: "decimal(18,8)", precision: 18, scale: 8, nullable: false),
                    subtotal = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    vat_amount = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    total_amount = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    total_amount_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    delivery_location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    expected_date = table.Column<DateOnly>(type: "date", nullable: true),
                    incoterms = table.Column<string>(type: "varchar(16)", maxLength: 16, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    status = table.Column<string>(type: "enum('DRAFT','PENDING_APPROVAL','APPROVED','REJECTED','SENT_TO_SUPPLIER','PARTIALLY_RECEIVED','FULLY_RECEIVED','CLOSED','CANCELLED')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    sent_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    updated_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_proc_purchase_order", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "proc_requisition",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_no = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    doc_date = table.Column<DateOnly>(type: "date", nullable: false),
                    requester_location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    product_type = table.Column<string>(type: "enum('FOOD','NON_FOOD')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    priority = table.Column<string>(type: "enum('LOW','NORMAL','HIGH','URGENT')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    required_date = table.Column<DateOnly>(type: "date", nullable: true),
                    status = table.Column<string>(type: "enum('DRAFT','SUBMITTED','IN_PROCUREMENT','CONVERTED_TO_PO','REJECTED','CANCELLED','CLOSED')", nullable: false)
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
                    table.PrimaryKey("pk_proc_requisition", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "proc_approval_step",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    instance_id = table.Column<long>(type: "bigint", nullable: false),
                    step_no = table.Column<byte>(type: "tinyint unsigned", nullable: false),
                    approver_user_id = table.Column<uint>(type: "int unsigned", nullable: true),
                    delegated_from_user_id = table.Column<uint>(type: "int unsigned", nullable: true),
                    decision = table.Column<string>(type: "enum('PENDING','APPROVED','REJECTED')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    decided_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    comment = table.Column<string>(type: "varchar(1000)", maxLength: 1000, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_proc_approval_step", x => x.id);
                    table.ForeignKey(
                        name: "fk_proc_approval_step_proc_approval_instance_instance_id",
                        column: x => x.instance_id,
                        principalTable: "proc_approval_instance",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "proc_purchase_order_line",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    po_id = table.Column<long>(type: "bigint", nullable: false),
                    line_no = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    requisition_line_id = table.Column<long>(type: "bigint", nullable: true),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    unit_price = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    vat_rate = table.Column<decimal>(type: "decimal(9,4)", precision: 9, scale: 4, nullable: false),
                    line_total = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    received_qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_proc_purchase_order_line", x => x.id);
                    table.ForeignKey(
                        name: "fk_proc_purchase_order_line_proc_purchase_order_po_id",
                        column: x => x.po_id,
                        principalTable: "proc_purchase_order",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "proc_requisition_line",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    requisition_id = table.Column<long>(type: "bigint", nullable: false),
                    line_no = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    converted_qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_proc_requisition_line", x => x.id);
                    table.ForeignKey(
                        name: "fk_proc_requisition_line_proc_requisition_requisition_id",
                        column: x => x.requisition_id,
                        principalTable: "proc_requisition",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "ix_ai",
                table: "proc_approval_instance",
                columns: new[] { "tenant_id", "doc_type", "doc_id" });

            migrationBuilder.CreateIndex(
                name: "ix_rule",
                table: "proc_approval_rule",
                columns: new[] { "tenant_id", "doc_type", "product_type", "min_amount_base" });

            migrationBuilder.CreateIndex(
                name: "ix_as",
                table: "proc_approval_step",
                columns: new[] { "instance_id", "step_no" });

            migrationBuilder.CreateIndex(
                name: "uq_po",
                table: "proc_purchase_order",
                columns: new[] { "tenant_id", "doc_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_proc_purchase_order_line_po_id",
                table: "proc_purchase_order_line",
                column: "po_id");

            migrationBuilder.CreateIndex(
                name: "uq_pol",
                table: "proc_purchase_order_line",
                columns: new[] { "tenant_id", "po_id", "line_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_pr",
                table: "proc_requisition",
                columns: new[] { "tenant_id", "doc_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_proc_requisition_line_requisition_id",
                table: "proc_requisition_line",
                column: "requisition_id");

            migrationBuilder.CreateIndex(
                name: "uq_prl",
                table: "proc_requisition_line",
                columns: new[] { "tenant_id", "requisition_id", "line_no" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "proc_approval_rule");

            migrationBuilder.DropTable(
                name: "proc_approval_step");

            migrationBuilder.DropTable(
                name: "proc_purchase_order_line");

            migrationBuilder.DropTable(
                name: "proc_requisition_line");

            migrationBuilder.DropTable(
                name: "proc_approval_instance");

            migrationBuilder.DropTable(
                name: "proc_purchase_order");

            migrationBuilder.DropTable(
                name: "proc_requisition");
        }
    }
}
