using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.Inventory.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260921_Inventory_Count : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "inv_count",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    doc_no = table.Column<string>(type: "varchar(32)", maxLength: 32, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    count_type = table.Column<string>(type: "enum('FULL','CYCLE','SPOT')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    status = table.Column<string>(type: "enum('DRAFT','FROZEN','COUNTING','REVIEW','APPROVED','POSTED','CANCELLED')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    frozen_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    approved_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    approved_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    adjust_group_id = table.Column<long>(type: "bigint", nullable: true),
                    requires_approval = table.Column<bool>(type: "tinyint(1)", nullable: false, defaultValue: false),
                    note = table.Column<string>(type: "varchar(1000)", maxLength: 1000, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    scope_category_ids = table.Column<string>(type: "varchar(2000)", maxLength: 2000, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    scope_product_ids = table.Column<string>(type: "varchar(2000)", maxLength: 2000, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    updated_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_count", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "inv_count_line",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    count_id = table.Column<long>(type: "bigint", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    batch_id = table.Column<long>(type: "bigint", nullable: true),
                    book_qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    counted_qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    variance_qty = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: true),
                    variance_pct = table.Column<decimal>(type: "decimal(9,4)", precision: 9, scale: 4, nullable: true),
                    reason_code_id = table.Column<ushort>(type: "smallint unsigned", nullable: true),
                    note = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    counted_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    counted_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    avg_unit_cost = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false, defaultValue: 0m)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_inv_count_line", x => x.id);
                    table.ForeignKey(
                        name: "fk_inv_count_line_inv_count_count_id",
                        column: x => x.count_id,
                        principalTable: "inv_count",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "ix_count_loc",
                table: "inv_count",
                columns: new[] { "tenant_id", "location_id", "status" });

            migrationBuilder.CreateIndex(
                name: "uq_count",
                table: "inv_count",
                columns: new[] { "tenant_id", "doc_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_cl",
                table: "inv_count_line",
                columns: new[] { "tenant_id", "count_id", "product_id" });

            migrationBuilder.CreateIndex(
                name: "ix_inv_count_line_count_id",
                table: "inv_count_line",
                column: "count_id");

            migrationBuilder.CreateIndex(
                name: "uq_cl_line",
                table: "inv_count_line",
                columns: new[] { "tenant_id", "count_id", "product_id", "batch_id" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "inv_count_line");

            migrationBuilder.DropTable(
                name: "inv_count");
        }
    }
}
