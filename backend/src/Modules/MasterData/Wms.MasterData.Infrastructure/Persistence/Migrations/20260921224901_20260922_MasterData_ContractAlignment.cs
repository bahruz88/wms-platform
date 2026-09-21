using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.MasterData.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260922_MasterData_ContractAlignment : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<uint>(
                name: "row_version",
                table: "master_reason_code",
                type: "int unsigned",
                nullable: false,
                defaultValue: 1u);

            migrationBuilder.AddColumn<string>(
                name: "default_issue_strategy",
                table: "master_product_category",
                type: "enum('FEFO','FIFO')",
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<bool>(
                name: "is_active",
                table: "master_product_category",
                type: "tinyint(1)",
                nullable: false,
                defaultValue: true);

            migrationBuilder.AddColumn<uint>(
                name: "row_version",
                table: "master_product_category",
                type: "int unsigned",
                nullable: false,
                defaultValue: 1u);

            migrationBuilder.AddColumn<uint>(
                name: "row_version",
                table: "master_location",
                type: "int unsigned",
                nullable: false,
                defaultValue: 1u);

            migrationBuilder.CreateIndex(
                name: "ix_reason_group",
                table: "master_reason_code",
                columns: new[] { "tenant_id", "reason_group" });

            migrationBuilder.CreateIndex(
                name: "ix_cat_path",
                table: "master_product_category",
                columns: new[] { "tenant_id", "path" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "ix_reason_group",
                table: "master_reason_code");

            migrationBuilder.DropIndex(
                name: "ix_cat_path",
                table: "master_product_category");

            migrationBuilder.DropColumn(
                name: "row_version",
                table: "master_reason_code");

            migrationBuilder.DropColumn(
                name: "default_issue_strategy",
                table: "master_product_category");

            migrationBuilder.DropColumn(
                name: "is_active",
                table: "master_product_category");

            migrationBuilder.DropColumn(
                name: "row_version",
                table: "master_product_category");

            migrationBuilder.DropColumn(
                name: "row_version",
                table: "master_location");
        }
    }
}
