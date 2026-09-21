using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.Inventory.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260921_Inventory_WarehouseDocuments : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "inv_issue",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_no = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    doc_date = table.Column<DateOnly>(type: "date", nullable: false),
                    issue_type = table.Column<string>(type: "enum('BRANCH_ISSUE','WH_TRANSFER','BRANCH_TRANSFER')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    from_location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    to_location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    request_id = table.Column<long>(type: "bigint", nullable: true),
                    status = table.Column<string>(type: "enum('DRAFT','DISPATCHED','RECEIVED','DISCREPANCY','CANCELLED')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    dispatch_group_id = table.Column<long>(type: "bigint", nullable: true),
                    receipt_group_id = table.Column<long>(type: "bigint", nullable: true),
                    dispatched_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    received_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    received_by = table.Column<uint>(type: "int unsigned", nullable: true),
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
                    table.PrimaryKey("pk_inv_issue", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_return_to_vendor",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_no = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    doc_date = table.Column<DateOnly>(type: "date", nullable: false),
                    supplier_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    receipt_id = table.Column<long>(type: "bigint", nullable: true),
                    reason_code_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    claim_amount = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    status = table.Column<string>(type: "enum('DRAFT','SENT','ACCEPTED','REJECTED','CLOSED')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    movement_group_id = table.Column<long>(type: "bigint", nullable: true),
                    outcome = table.Column<string>(type: "varchar(16)", maxLength: 16, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    outcome_note = table.Column<string>(type: "varchar(1000)", maxLength: 1000, nullable: true)
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
                    table.PrimaryKey("pk_inv_return_to_vendor", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_sample",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_no = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    doc_date = table.Column<DateOnly>(type: "date", nullable: false),
                    location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    authority = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    purpose = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    reason_code_id = table.Column<ushort>(type: "smallint unsigned", nullable: true),
                    movement_group_id = table.Column<long>(type: "bigint", nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    updated_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_sample", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_stock_request",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_no = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    doc_date = table.Column<DateOnly>(type: "date", nullable: false),
                    from_location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    to_location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    required_date = table.Column<DateOnly>(type: "date", nullable: true),
                    status = table.Column<string>(type: "enum('DRAFT','SUBMITTED','PICKING','PARTIALLY_ISSUED','ISSUED','CANCELLED','CLOSED')", nullable: false)
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
                    table.PrimaryKey("pk_inv_stock_request", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_waste",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_no = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    doc_date = table.Column<DateOnly>(type: "date", nullable: false),
                    location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    reason_code_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    status = table.Column<string>(type: "enum('DRAFT','PENDING_APPROVAL','APPROVED','POSTED','REJECTED')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    approved_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    approved_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    approval_comment = table.Column<string>(type: "varchar(1000)", maxLength: 1000, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    movement_group_id = table.Column<long>(type: "bigint", nullable: true),
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
                    table.PrimaryKey("pk_inv_waste", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_issue_line",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    issue_id = table.Column<long>(type: "bigint", nullable: false),
                    line_no = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    request_line_id = table.Column<long>(type: "bigint", nullable: true),
                    qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    qty_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false, defaultValue: 0m),
                    batch_id = table.Column<long>(type: "bigint", nullable: true),
                    suggested_batch_id = table.Column<long>(type: "bigint", nullable: true),
                    batch_override_reason_code_id = table.Column<ushort>(type: "smallint unsigned", nullable: true),
                    batch_override_note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    received_qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    discrepancy_qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    discrepancy_reason_code_id = table.Column<ushort>(type: "smallint unsigned", nullable: true),
                    discrepancy_note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    unit_cost = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_issue_line", x => x.id);
                    table.ForeignKey(
                        name: "fk_inv_issue_line_inv_issue_issue_id",
                        column: x => x.issue_id,
                        principalTable: "inv_issue",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_return_to_vendor_line",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    return_id = table.Column<long>(type: "bigint", nullable: false),
                    line_no = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    batch_id = table.Column<long>(type: "bigint", nullable: true),
                    qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    qty_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false, defaultValue: 0m),
                    unit_cost = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_return_to_vendor_line", x => x.id);
                    table.ForeignKey(
                        name: "fk_inv_return_to_vendor_line_inv_return_to_vendor_return_id",
                        column: x => x.return_id,
                        principalTable: "inv_return_to_vendor",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_sample_line",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    sample_id = table.Column<long>(type: "bigint", nullable: false),
                    line_no = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    batch_id = table.Column<long>(type: "bigint", nullable: true),
                    qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    qty_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false, defaultValue: 0m),
                    unit_cost = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_sample_line", x => x.id);
                    table.ForeignKey(
                        name: "fk_inv_sample_line_inv_sample_sample_id",
                        column: x => x.sample_id,
                        principalTable: "inv_sample",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_stock_request_line",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    request_id = table.Column<long>(type: "bigint", nullable: false),
                    line_no = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    issued_qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false, defaultValue: 0m),
                    note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_stock_request_line", x => x.id);
                    table.ForeignKey(
                        name: "fk_inv_stock_request_line_inv_stock_request_request_id",
                        column: x => x.request_id,
                        principalTable: "inv_stock_request",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_waste_line",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    waste_id = table.Column<long>(type: "bigint", nullable: false),
                    line_no = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    batch_id = table.Column<long>(type: "bigint", nullable: true),
                    qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    uom_id = table.Column<ushort>(type: "smallint unsigned", nullable: false),
                    qty_base = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false, defaultValue: 0m),
                    unit_cost = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_waste_line", x => x.id);
                    table.ForeignKey(
                        name: "fk_inv_waste_line_inv_waste_waste_id",
                        column: x => x.waste_id,
                        principalTable: "inv_waste",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "ix_issue_status",
                table: "inv_issue",
                columns: new[] { "tenant_id", "status", "to_location_id" });

            migrationBuilder.CreateIndex(
                name: "uq_issue",
                table: "inv_issue",
                columns: new[] { "tenant_id", "doc_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_inv_issue_line_issue_id",
                table: "inv_issue_line",
                column: "issue_id");

            migrationBuilder.CreateIndex(
                name: "uq_isl",
                table: "inv_issue_line",
                columns: new[] { "tenant_id", "issue_id", "line_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_rtv",
                table: "inv_return_to_vendor",
                columns: new[] { "tenant_id", "doc_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_inv_return_to_vendor_line_return_id",
                table: "inv_return_to_vendor_line",
                column: "return_id");

            migrationBuilder.CreateIndex(
                name: "uq_rtvl",
                table: "inv_return_to_vendor_line",
                columns: new[] { "tenant_id", "return_id", "line_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_sample",
                table: "inv_sample",
                columns: new[] { "tenant_id", "doc_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_inv_sample_line_sample_id",
                table: "inv_sample_line",
                column: "sample_id");

            migrationBuilder.CreateIndex(
                name: "uq_sml",
                table: "inv_sample_line",
                columns: new[] { "tenant_id", "sample_id", "line_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_sr_to",
                table: "inv_stock_request",
                columns: new[] { "tenant_id", "to_location_id", "status" });

            migrationBuilder.CreateIndex(
                name: "uq_sr",
                table: "inv_stock_request",
                columns: new[] { "tenant_id", "doc_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_inv_stock_request_line_request_id",
                table: "inv_stock_request_line",
                column: "request_id");

            migrationBuilder.CreateIndex(
                name: "uq_srl",
                table: "inv_stock_request_line",
                columns: new[] { "tenant_id", "request_id", "line_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_waste_loc",
                table: "inv_waste",
                columns: new[] { "tenant_id", "location_id", "status" });

            migrationBuilder.CreateIndex(
                name: "uq_waste",
                table: "inv_waste",
                columns: new[] { "tenant_id", "doc_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_inv_waste_line_waste_id",
                table: "inv_waste_line",
                column: "waste_id");

            migrationBuilder.CreateIndex(
                name: "uq_wl",
                table: "inv_waste_line",
                columns: new[] { "tenant_id", "waste_id", "line_no" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "inv_issue_line");

            migrationBuilder.DropTable(
                name: "inv_return_to_vendor_line");

            migrationBuilder.DropTable(
                name: "inv_sample_line");

            migrationBuilder.DropTable(
                name: "inv_stock_request_line");

            migrationBuilder.DropTable(
                name: "inv_waste_line");

            migrationBuilder.DropTable(
                name: "inv_issue");

            migrationBuilder.DropTable(
                name: "inv_return_to_vendor");

            migrationBuilder.DropTable(
                name: "inv_sample");

            migrationBuilder.DropTable(
                name: "inv_stock_request");

            migrationBuilder.DropTable(
                name: "inv_waste");
        }
    }
}
