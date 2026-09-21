using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Wms.MasterData.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class _20260921_MasterData_ConsumptionLocationType : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "location_type",
                table: "master_location",
                type: "enum('CENTRAL_WAREHOUSE','SUB_LOCATION','SHELF','RESTAURANT','IN_TRANSIT','V_SUPPLIER','V_WASTE','V_SAMPLE','V_ADJUSTMENT','V_CONSUMPTION')",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "enum('CENTRAL_WAREHOUSE','SUB_LOCATION','SHELF','RESTAURANT','IN_TRANSIT','V_SUPPLIER','V_WASTE','V_SAMPLE','V_ADJUSTMENT')")
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "location_type",
                table: "master_location",
                type: "enum('CENTRAL_WAREHOUSE','SUB_LOCATION','SHELF','RESTAURANT','IN_TRANSIT','V_SUPPLIER','V_WASTE','V_SAMPLE','V_ADJUSTMENT')",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "enum('CENTRAL_WAREHOUSE','SUB_LOCATION','SHELF','RESTAURANT','IN_TRANSIT','V_SUPPLIER','V_WASTE','V_SAMPLE','V_ADJUSTMENT','V_CONSUMPTION')")
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");
        }
    }
}
