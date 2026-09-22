using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.Reporting.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260922_Reporting_CatalogueAndExports : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "columns_json",
                table: "rpt_report_definition",
                type: "json",
                nullable: false)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "description",
                table: "rpt_report_definition",
                type: "varchar(1000)",
                maxLength: 1000,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<int>(
                name: "max_sync_rows",
                table: "rpt_report_definition",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "parameters_json",
                table: "rpt_report_definition",
                type: "json",
                nullable: false)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<bool>(
                name: "requires_cost_permission",
                table: "rpt_report_definition",
                type: "tinyint(1)",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<ushort>(
                name: "sort_order",
                table: "rpt_report_definition",
                type: "smallint unsigned",
                nullable: false,
                defaultValue: (ushort)0);

            migrationBuilder.AddColumn<string>(
                name: "supported_formats",
                table: "rpt_report_definition",
                type: "varchar(64)",
                maxLength: 64,
                nullable: false,
                defaultValue: "")
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "tor_ref",
                table: "rpt_report_definition",
                type: "varchar(32)",
                maxLength: 32,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "rpt_export_job",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    tenant_id = table.Column<uint>(type: "int unsigned", nullable: false),
                    report_code = table.Column<string>(type: "varchar(48)", maxLength: 48, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    format = table.Column<string>(type: "enum('XLSX','CSV','PDF')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    status = table.Column<string>(type: "enum('QUEUED','RUNNING','COMPLETED','FAILED','CANCELLED')", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    progress_pct = table.Column<byte>(type: "tinyint unsigned", nullable: true),
                    row_count = table.Column<long>(type: "bigint", nullable: true),
                    file_name = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    size_bytes = table.Column<long>(type: "bigint", nullable: true),
                    storage_key = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    error_message = table.Column<string>(type: "varchar(1000)", maxLength: 1000, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    parameters_json = table.Column<string>(type: "json", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    location_scope_json = table.Column<string>(type: "json", nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    include_cost = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    locale = table.Column<string>(type: "varchar(16)", maxLength: 16, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    requested_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    requested_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    started_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    completed_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    expires_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    idempotency_key = table.Column<Guid>(type: "char(36)", maxLength: 36, nullable: false, collation: "ascii_general_ci"),
                    created_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: false),
                    created_by = table.Column<uint>(type: "int unsigned", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "datetime(3)", precision: 3, nullable: true),
                    updated_by = table.Column<uint>(type: "int unsigned", nullable: true),
                    row_version = table.Column<uint>(type: "int unsigned", nullable: false, defaultValue: 1u)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_rpt_export_job", x => x.id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "ix_rpt_report_cat",
                table: "rpt_report_definition",
                columns: new[] { "tenant_id", "category", "sort_order" });

            migrationBuilder.CreateIndex(
                name: "ix_rpt_export_status",
                table: "rpt_export_job",
                columns: new[] { "tenant_id", "status", "requested_at" });

            migrationBuilder.CreateIndex(
                name: "ix_rpt_export_user",
                table: "rpt_export_job",
                columns: new[] { "tenant_id", "requested_by", "requested_at" });

            migrationBuilder.CreateIndex(
                name: "uq_rpt_export_idem",
                table: "rpt_export_job",
                columns: new[] { "tenant_id", "requested_by", "idempotency_key" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "rpt_export_job");

            migrationBuilder.DropIndex(
                name: "ix_rpt_report_cat",
                table: "rpt_report_definition");

            migrationBuilder.DropColumn(
                name: "columns_json",
                table: "rpt_report_definition");

            migrationBuilder.DropColumn(
                name: "description",
                table: "rpt_report_definition");

            migrationBuilder.DropColumn(
                name: "max_sync_rows",
                table: "rpt_report_definition");

            migrationBuilder.DropColumn(
                name: "parameters_json",
                table: "rpt_report_definition");

            migrationBuilder.DropColumn(
                name: "requires_cost_permission",
                table: "rpt_report_definition");

            migrationBuilder.DropColumn(
                name: "sort_order",
                table: "rpt_report_definition");

            migrationBuilder.DropColumn(
                name: "supported_formats",
                table: "rpt_report_definition");

            migrationBuilder.DropColumn(
                name: "tor_ref",
                table: "rpt_report_definition");
        }
    }
}
