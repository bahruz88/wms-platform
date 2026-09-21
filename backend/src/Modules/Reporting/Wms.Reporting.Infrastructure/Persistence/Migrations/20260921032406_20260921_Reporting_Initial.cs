using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.Reporting.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260921_Reporting_Initial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "rpt_report_definition",
                columns: table => new
                {
                    id = table.Column<ushort>(type: "smallint unsigned", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    code = table.Column<string>(type: "varchar(48)", maxLength: 48, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    name = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    category = table.Column<string>(type: "varchar(64)", maxLength: 64, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    supports_excel_export = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    is_active = table.Column<bool>(type: "tinyint(1)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_rpt_report_definition", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "rpt_stock_snapshot",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    snapshot_date = table.Column<DateOnly>(type: "date", nullable: false),
                    product_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    location_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    qty_on_hand = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    avg_unit_cost = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    total_value = table.Column<decimal>(type: "decimal(18,4)", precision: 18, scale: 4, nullable: false),
                    built_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_rpt_stock_snapshot", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "uq_rpt_report",
                table: "rpt_report_definition",
                columns: new[] { "tenant_id", "code" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_rpt_snapshot_loc",
                table: "rpt_stock_snapshot",
                columns: new[] { "tenant_id", "snapshot_date", "location_id" });

            migrationBuilder.CreateIndex(
                name: "uq_rpt_snapshot",
                table: "rpt_stock_snapshot",
                columns: new[] { "tenant_id", "snapshot_date", "product_id", "location_id" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "rpt_report_definition");

            migrationBuilder.DropTable(
                name: "rpt_stock_snapshot");
        }
    }
}
